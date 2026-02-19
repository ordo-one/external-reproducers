import Essentials

public protocol _Storage: Sendable {
    var value: FrozenStructure { get }
    var description: String? { get set }
}

public struct StorageStruct: _Storage, Sendable {
    public let value: FrozenStructure
    public var description: String?

    public init(_ value: FrozenStructure) {
        self.value = value
    }
}
