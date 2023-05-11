import Api

public actor MyPlugin: Plugin {
    public init() {
        print("  MyPlugin:init")
    }
    
    deinit {
        print("  MyPlugin:deinit")
    }
}

@_cdecl("bundleFactory")
public func bundleFactory() -> UnsafeMutableRawPointer {
    Unmanaged.passRetained(PluginFactory(MyPlugin.self)).toOpaque()
}
