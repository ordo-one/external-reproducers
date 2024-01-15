import OrdoEssentials

public protocol Plugin: Actor {
    init()
    
    func handle(_ transaction: Transaction) -> TransactionUpdate
}

public protocol SomeProtocol {
    func doSomething() async
}

public final class PluginFactory: BundleFactory {
    public typealias FactoryType = Plugin

    fileprivate let bundleType: FactoryType.Type

    public init(_ bundleType: FactoryType.Type) {
        self.bundleType = bundleType
    }
    
    deinit { }

    public func makeInstance() -> FactoryType {
        bundleType.init()
    }
}

public class Frostflake {
    static var id: Int?
    
    public static func setup(_ value: Int) {
        id = value
    }
    
    public static func make() -> Int? {
        guard let id else {
            return nil
        }
        return id
    }
}

public func publicTestMarket(_ market: String) -> Bool {
    return Markets.hasMarket(market)
}
