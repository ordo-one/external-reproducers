public protocol BundleFactory: AnyObject {
    associatedtype FactoryType

    func makeInstance() -> FactoryType
    func compatible(withType: AnyObject.Type) -> Bool
}

public extension BundleFactory {
    func compatible(withType: AnyObject.Type) -> Bool {
        if String(describing: withType) == String(describing: Self.self) {
            return true
        }
        return false
    }
}
