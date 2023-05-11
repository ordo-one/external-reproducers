import Bundle
import BundleManager
import SystemPackage
import Api

public class GenericLoading {
    var factories: [String: any BundleFactory] = [:]

    public init() {}

    /// Generic bundle loader
    func loadPlugins<Factory: BundleFactory>(at path: FilePath, of _: Factory.Type) async throws {
        let bundleManager = try await BundleManager<Factory>(withPath: path, loadBundles: true)
        let bundles = await bundleManager.bundles
        for (path, bundle) in bundles {
            guard let name = path.lastComponent?.stem.dropFirst("lib".count) else {
                fatalError("Can't parse plugin type name from '\(path)'")
            }
            let pluginName = String(name)
            print("Plugin '\(pluginName)' has been loaded, let's try to create it:")
            
            // Checking that we can instantiate the plugin using the factory
            _ = bundle.factory.makeInstance()
            
            factories[pluginName] = bundle.factory
        }
    }

    func instantiate<T>(plugin info: String, ofType _: T.Type) throws -> T {
        let pluginFactory = factories[info]

        guard let pluginFactory else {
            fatalError()
        }
        
        print("Found factory of type: \(pluginFactory.self), now trying to instantiate")

        let plugin = pluginFactory.makeInstance()

        guard let typedPlugin = plugin as? T else {
            fatalError()
        }

        return typedPlugin
    }
    
    public func run() async throws {
        try await loadPlugins(at: "../Lib/.build/release/", of: PluginFactory.self)
        print("Loading done, now let's find and create plugin with name 'Lib'")
        let plugin = try instantiate(plugin: "Lib", ofType: Plugin.self)
        print("Done, shutting down")
    }
}
