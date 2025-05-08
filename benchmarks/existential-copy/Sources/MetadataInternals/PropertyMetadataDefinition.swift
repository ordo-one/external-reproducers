public protocol PropertyMetadataDefinition: Sendable {
    var id: UInt64 { get }
    var a: String { get }
    var b: String { get }
}

public struct PropertyMetadataStruct: PropertyMetadataDefinition {
    public let id: UInt64
    public let a: String
    public let b: String

    public init(id: UInt64, a: String, b: String) {
        self.id = id
        self.a = a
        self.b = b
    }
}

public final class PropertyMetadataClass: PropertyMetadataDefinition {
    public let id: UInt64
    public let a: String
    public let b: String

    public init(id: UInt64, a: String, b: String) {
        self.id = id
        self.a = a
        self.b = b
    }
}

public final class PropertyMetadataClassWrapper: PropertyMetadataDefinition {
    private let wrapped: any PropertyMetadataDefinition

    public init(id: UInt64, a: String, b: String) {
        self.wrapped = PropertyMetadataStruct.init(id: id, a: a, b: b)
    }

    public var id: UInt64 { wrapped.id }
    public var a: String { wrapped.a }
    public var b: String { wrapped.b }
}
