@frozen
public struct FrozenStructure: Sendable {
    @usableFromInline
    var rawValue: Int

    @inlinable
    public init(_ value: Int) {
        self.rawValue = value
    }

    @inlinable
    public init?(_ value: Int?) {
        guard let value else { return nil }
        self.rawValue = value
    }
}
