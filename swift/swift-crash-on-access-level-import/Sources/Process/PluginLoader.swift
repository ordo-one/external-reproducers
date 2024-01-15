import OrdoPublic
import SystemPackage

public class PluginLoader {
    var factories: [String: PluginFactory] = [:]

    public init() {}

    /// Generic bundle loader
    func loadPlugins(at path: FilePath) async throws {
        let bundleManager = try await BundleManager<PluginFactory>(withPath: path, loadBundles: true)
        let bundles = await bundleManager.bundles
        for (path, bundle) in bundles {
            guard let name = path.lastComponent?.stem.dropFirst("lib".count) else {
                fatalError("FAIL: Plugin can't be loaded from '\(path)'")
            }
            let pluginName = String(name)
            print("OK: plugin '\(pluginName)' has been loaded")

            // Checking that we can instantiate the plugin using the factory
            _ = bundle.factory.makeInstance()

            factories[pluginName] = bundle.factory
        }
    }

    func instantiate<T>(plugin info: String, ofType _: T.Type) throws -> T {
        let pluginFactory = factories[info]

        guard let pluginFactory else {
            fatalError("FAIL: Plugin factory is no found")
        }

        let plugin = pluginFactory.makeInstance()

        guard let typedPlugin = plugin as? T else {
            fatalError("FAIL: Plugin can't be instantiated")
        }

        print("OK: Plugin is instantiated")
        
        return typedPlugin
    }
}
