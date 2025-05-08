import MetadataInternals

public struct X: Sendable {
    private let definition: any PropertyMetadataDefinition

    public init(definition: any PropertyMetadataDefinition) {
        self.definition = definition
    }

    public var id: UInt64 { self.definition.id }
    public var a: String { self.definition.a }
    public var b: String { self.definition.b }
}

public struct Y: Sendable {
    private let definition: PropertyMetadataStruct

    public init(definition: PropertyMetadataStruct) {
        self.definition = definition
    }

    public var id: UInt64 { self.definition.id }
    public var a: String { self.definition.a }
    public var b: String { self.definition.b }
}

public struct Z: Sendable {
    private let definition: PropertyMetadataClass

    public init(definition: PropertyMetadataClass) {
        self.definition = definition
    }

    public var id: UInt64 { self.definition.id }
    public var a: String { self.definition.a }
    public var b: String { self.definition.b }
}

public enum E {
    public static let x: X = .init(definition: PropertyMetadataStruct.init(
        id: 1,
        a: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        b: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    ))
    public static let y: Y = .init(definition: PropertyMetadataStruct.init(
        id: 1,
        a: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        b: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    ))
    public static let z: Z = .init(definition: PropertyMetadataClass.init(
        id: 1,
        a: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        b: "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    ))
}
