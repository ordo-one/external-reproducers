/// Public-facing `Timestamp` struct exposed to callers of the Reproducer module.
///
/// Mirrors `Timestamp` from package-data-model's `OrdoEssentials`. The accessor on
/// `PublicTrade` converts the FlatBuffers struct (`Repro_Timestamp`) into this
/// public type, so this is the leaf of the inlining chain we're studying.
public struct Timestamp: Sendable, Equatable, Hashable {
    public var nanosecondsSinceUnixEpoch: UInt64

    @inlinable
    public init(nanosecondsSinceUnixEpoch: UInt64) {
        self.nanosecondsSinceUnixEpoch = nanosecondsSinceUnixEpoch
    }

    /// Bridge from the FlatBuffers struct. Kept `@inlinable` so the compiler is
    /// free to fold this into callers — mirrors `Timestamp+StructBridge` in
    /// package-data-model.
    @inlinable
    init(_ fb: Repro_Timestamp) {
        self.init(nanosecondsSinceUnixEpoch: fb.nanosecondsSinceUnixEpoch)
    }
}
