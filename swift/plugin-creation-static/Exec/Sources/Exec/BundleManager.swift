// ===----------------------------------------------------------------------=== //
//
// This source file is part of the BundleManager open source project
//
// See LICENSE for license information
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------=== //

import Api
import Logging
import SystemPackage

#if canImport(Darwin)
    import Darwin
    typealias DirectoryStreamPointer = UnsafeMutablePointer<DIR>?
#elseif canImport(Glibc)
    import Glibc
    typealias DirectoryStreamPointer = OpaquePointer?
#else
    #error("Unsupported Platform")
#endif

/// The coordinator that dynamically loads bundle shared library
public actor BundleManager<T: BundleFactory> {
    public static var defaultBinaryExtension: String {
        #if canImport(Darwin)
            return "dylib"
        #elseif canImport(Glibc)
            return "so"
        #else
            #error("Unsupported Platform")
        #endif
    }

    /// A successfully loaded bundle instance using the bundle dynamic library path as the key.
    ///
    public struct Bundle {
        /// The path to the bundle dynamic library.
        ///
        public var path: FilePath
        /// An instance of the factory class for this ``BundleManager`` that can create an instances.
        ///
        /// ```swift
        ///  var instance = bundle.factory.makeInstance()
        ///  print(instance.name())
        /// ```
        ///
        public var factory: T
        fileprivate var _dlHandle: UnsafeMutableRawPointer?
    }

    /// The currently successfully loaded bundles which can be used to create instances.
    ///
    ///
    /// ```swift
    ///  let bundleManager = try await BundleManager<BundleExampleAPIFactory>(withPath: validPath)
    ///  let bundleCount = await bundleManager.bundles.count
    ///
    ///  for (_, bundle) in await bundleManager.bundles {
    ///    var instance = bundle.factory.makeInstance()
    ///    instance.setBundleManagerExampleAPI(BundleManagerExampleAPIProvider())
    ///    print(instance.name())
    ///  }
    /// ```
    ///
    public var bundles: [FilePath: Bundle] = [:]

    private var bundleDirectory: FilePath = "/tmp/bundles"
    private let logger = Logger(label: "BundleManager")
    private let bundleSuffix: String

    /// Initialize the ``BundleManager`` and dynamically load bundle instances.
    /// By default all bundle shared libraries will be loaded from the given path.
    ///
    /// - Parameters:
    ///   - directoryPath: The filesystem directory path from where bundles will be loaded
    ///   - binaryExtension: Specifies a custom binary extension to use,
    ///   otherwise use the platform default (.dylib/.so/.dll)
    ///   - loadBundles: Whether to load all the bundles from the specified directory as
    ///   part of initialization, by default they will be loaded.
    public init(withPath directoryPath: FilePath,
                binaryExtension: String? = nil,
                loadBundles: Bool = true) async throws {
        bundleDirectory = directoryPath

        if let bundleSuffix = binaryExtension {
            self.bundleSuffix = bundleSuffix
        } else {
            bundleSuffix = Self.defaultBinaryExtension
        }

        if loadBundles {
            try self.loadBundles()
        }
    }

    /// Singleton loading of a specific bundle factory as a convenience for workflows requiring it
    ///
    /// - Parameters:
    ///   - bundlePath: The concrete full path to the bundle to load including extension
    ///   (.so/.dylib/.dll - can use T.defaultBinaryExtension to get it)
    ///
    /// ```swift
    ///  let bundleFactory = try await BundleManager<BundleExampleAPIFactory>.makeFactory(withPath: validPath)
    ///
    ///  var instance = bundleFactory.makeInstance()
    ///
    ///  instance.setBundleManagerExampleAPI(BundleManagerExampleAPIProvider())
    ///
    ///  print(instance.name())
    /// ```
    ///
    public static func makeFactory(withPath bundlePath: FilePath) async throws -> T {
        var path = bundlePath
        if path.extension == nil {
            path.extension = Self.defaultBinaryExtension
        }

        if path.extension == Self.defaultBinaryExtension {
            let bundleManager = try await BundleManager<T>(withPath: path, loadBundles: false)

            try await bundleManager.load(bundle: path)

            for (_, bundle) in await bundleManager.bundles {
                return bundle.factory
            }
        } else {
            throw BundleManagerError.failedToLoadBundle(
                path: path,
                errorMessage: """
                Loading bundle from a different platform, expected extension \
                is \(Self.defaultBinaryExtension)
                """
            )
        }
        throw BundleManagerError.failedToLoadBundle(path: path, errorMessage: "Generic load failure")
    }
}

public extension BundleManager {
    internal typealias BundleFactoryFunctionPointer = @convention(c) () -> UnsafeMutableRawPointer

    private func loadBundles() throws {
        logger.debug("Loading bundles from [\(bundleDirectory)] of type \(String(describing: T.self)).")
        for file in bundleDirectory.directoryEntries where file.extension == bundleSuffix {
            do {
                try load(bundle: file)
            } catch let BundleManagerError.missingBundleModuleEntrypoint(path, reason) {
                logger.debug(
                    "loadBundle missing bundle module entry point for [\(path)], failed with reason [\(reason)]")
            } catch let BundleManagerError.incompatibleFactoryClass(path) {
                logger.debug("loadBundle failed due to an incompatible factory class for [\(path)]")
            }
        }
        logger.debug("Loaded \(bundles.count) bundles.")
    }

    private func _resolveFactoryFor(_ dlHandle: UnsafeMutableRawPointer?, _ symbol: String) -> T? {
        let bundleFactorySymbolReference = dlsym(dlHandle, symbol)

        guard bundleFactorySymbolReference != nil else {
            return nil
        }

        let bundleFactoryCreator: BundleFactoryFunctionPointer = unsafeBitCast(bundleFactorySymbolReference,
                                                                               to: BundleFactoryFunctionPointer.self)
        let bundleFactory = Unmanaged<T>.fromOpaque(bundleFactoryCreator()).takeRetainedValue() as T

        return bundleFactory
    }

    /// Try to load a specific bundle from the given path
    /// - Parameter path: The full path to the specific bundle to load including suffix,
    /// e.g. `/usr/local/bundles/mybundle.dylib`
    /// - Throws: ``BundleManagerError``
    ///
    /// ```swift
    ///  let bundleManager = try await BundleManager<BundleExampleAPIFactory>(withPath: "", loadBundles: false)
    ///
    ///  try await bundleManager.load(bundle: "/usr/local/bundles/mybundle.dylib").
    /// ```
    func load(bundle path: FilePath) throws {
        if bundles[path] != nil {
            logger.debug("load bundle called for \(path) which was already loaded")
            throw BundleManagerError.duplicateBundle(path)
        }

        logger.debug("Loading bundle [\(path)]")

        try path.withPlatformString {
            // To fix: Check RTLD_ flags to use again
            guard let dlHandle = dlopen($0, RTLD_NOW | RTLD_LOCAL | RTLD_NODELETE) else {
                throw BundleManagerError.failedToLoadBundle(path: path, errorMessage: String(cString: dlerror()))
            }

            guard let bundleFactory = _resolveFactoryFor(dlHandle, "bundleFactory") else {
                throw BundleManagerError.missingBundleModuleEntrypoint(path: path,
                                                                       errorMessage: String(cString: dlerror()))
            }

            guard bundleFactory.compatible(withType: T.self) else {
                throw BundleManagerError.incompatibleFactoryClass(path)
            }

            bundles[path] = Bundle(path: path, factory: bundleFactory, _dlHandle: dlHandle)
            logger.debug("Loaded bundle [\(path)] factory [\(String(describing: bundleFactory.self))]")
        }
    }

    /// Reload the bundle executable image to allow for on-the-fly new versions.
    /// Old instances will continue to run the original code.
    /// - Parameter path: The full path to the specific bundle to reload including suffix,
    /// e.g. `/usr/local/bundles/mybundle.dylib`
    func reload(bundle path: FilePath) throws {
        logger.debug("Reloading bundle \(path)")
        try unload(bundle: path)
        try load(bundle: path)
    }

    private func _unloadBundle(_ bundle: Bundle) {
        logger.debug("Unloading bundle \(bundle.path)")

        guard let dlHandle = bundle._dlHandle else {
            logger.debug("_unloadBundle called for bundle._dlHandle that was nil for [\(bundle.path)]")
            return
        }

        // We don't throw on a failed dlclose, but lets warn about it
        if dlclose(dlHandle) == -1 {
            logger.debug("dlclose failed with \(String(cString: dlerror()))")
        }
    }

    /// Unload the bundle executable image and remove it from the internal ``bundles`` dictionary.
    /// Existing instances will continue to run the original code loaded.
    /// - Parameter path: The full path to the specific bundle to unload including suffix,
    /// e.g. `/usr/local/bundles/mybundle.dylib`
    func unload(bundle path: FilePath) throws {
        guard let bundle = bundles[path] else {
            logger.debug("unloadBundle failed as \(path) was not a previously loaded bundle.")
            throw BundleManagerError.unknownBundle(path)
        }
        _unloadBundle(bundle)
        bundles[path] = nil
    }

    /// Unload all bundle executable images and remove them from the internal ``bundles`` dictionary.
    /// Existing bundle instances will continue to run the original code loaded.
    func unloadAll() {
        logger.debug("Unloading all bundle:")

        for (_, value) in bundles {
            _unloadBundle(value)
        }
        bundles.removeAll()
    }
}

/// Throwable errors from ``BundleManager`` operations
public enum BundleManagerError: Error {
    /// The loading of the bundle shared library (.dylib or .so) at the given path failed.
    case failedToLoadBundle(path: FilePath, errorMessage: String)
    /// The bundle is missing the required function entry point
    ///
    /// The bundle shared library must contain a `@_cdecl`'d function named `bundleFactory`
    /// that returns the factory class to be used.
    ///
    /// ```swift
    ///  @_cdecl("bundleFactory")
    ///  public func bundleFactory() -> UnsafeMutableRawPointer {
    ///    return Unmanaged.passRetained(BundleExampleAPIFactory(BundleExample.self)).toOpaque()
    ///  }
    /// ```
    case missingBundleModuleEntrypoint(path: FilePath, errorMessage: String)
    /// The factory class was of a different type than the generic factory type for this ``BundleManager``
    /// instance, so loading failed.
    case incompatibleFactoryClass(FilePath)
    /// Attempt to explcitily load a bundle that already was loaded by the ``BundleManager``
    case duplicateBundle(FilePath)
    /// Attempt to unload or reload a bundle that was unknown to the ``BundleManager``
    case unknownBundle(FilePath)
}

// Extends FilePath with basic directory iteration capabilities
public extension FilePath {
    /// `DirectoryView` provides an iteratable sequence of the contents of a directory referenced by a `FilePath`
    struct DirectoryView {
        internal var directoryStreamPointer: DirectoryStreamPointer = nil
        internal var path: FilePath

        /// Initializer
        /// - Parameter path: The file system path to provide directory entries for, should reference a directory
        internal init(path pathName: FilePath) {
            path = pathName
            path.withPlatformString {
                directoryStreamPointer = opendir($0)
            }
        }
    }

    var directoryEntries: DirectoryView { DirectoryView(path: self) }
}

extension FilePath.DirectoryView: IteratorProtocol, Sequence {
    public mutating func next() -> FilePath? {
        guard let streamPointer = directoryStreamPointer else {
            return nil
        }

        guard let directoryEntry = readdir(streamPointer) else {
            closedir(streamPointer)
            directoryStreamPointer = nil
            return nil
        }

        let fileName = withUnsafePointer(to: &directoryEntry.pointee.d_name) { pointer -> FilePath.Component in
            pointer.withMemoryRebound(to: CChar.self,
                                      capacity: MemoryLayout.size(ofValue: directoryEntry.pointee.d_name)) {
                guard let fileName = FilePath.Component(platformString: $0) else {
                    fatalError("Could not initialize FilePath.Component from platformString \(String(cString: $0))")
                }
                return fileName
            }
        }
        return path.appending(fileName)
    }
}
