import Bundle

/// Protocol to which any plugin must conform to be plugable.
public protocol Plugin: Actor {
    init()
}

/// Factory implementation for initializing plugin
public final class PluginFactory: BundleFactory {
    public typealias FactoryType = Plugin

    fileprivate let bundleType: FactoryType.Type

    public init(_ bundleType: FactoryType.Type) {
        print("  PluginFactory:init")
        self.bundleType = bundleType
    }
    
    deinit {
        print("  PluginFactory:deinit")
    }

    public func makeInstance() -> FactoryType {
        bundleType.init()
    }
}
