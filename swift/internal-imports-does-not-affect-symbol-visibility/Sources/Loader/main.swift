import Foundation

// Resolve libPluginA.dylib / libPluginB.dylib next to this executable.
let executableURL = URL(fileURLWithPath: CommandLine.arguments[0])
let base = executableURL.deletingLastPathComponent()

#if os(macOS)
let ext = "dylib"
#elseif os(Linux)
let ext = "so"
#else
#error("Not supported platform")
#endif

let libA = base.appendingPathComponent("libPluginA." + ext).path
let libB = base.appendingPathComponent("libPluginB." + ext).path

func open(_ path: String) -> UnsafeMutableRawPointer {
    print("Loading \(path)")
    guard let handle = dlopen(path, RTLD_NOW) else {
        let err = dlerror().map { String(cString: $0) } ?? "unknown"
        fatalError("dlopen failed for \(path): \(err)")
    }
    return handle
}

func sym(_ handle: UnsafeMutableRawPointer, _ name: String) -> @convention(c) () -> Int {
    guard let raw = dlsym(handle, name) else {
        let err = dlerror().map { String(cString: $0) } ?? "unknown"
        fatalError("dlsym \(name) failed: \(err)")
    }
    return unsafeBitCast(raw, to: (@convention(c) () -> Int).self)
}

let handleA = open(libA)
let handleB = open(libB)

let probeA = sym(handleA, "pluginA_probe")
let probeB = sym(handleB, "pluginB_probe")

print("PluginA probe = \(probeA())")
print("PluginB probe = \(probeB())")
print("Done.")
