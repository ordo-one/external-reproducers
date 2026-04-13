import FlatBuffers

/// Public wrapper around the FlatBuffers-generated `Repro_PublicTrade` reader.
///
/// This is the minimal shape of `PublicTrade` from package-data-model's
/// `OrdoPublic`, stripped down to a single struct field (`timeCreated`) and
/// without the `any _PublicTrade` existential indirection. The goal is to see
/// whether the accessor chain
///
///     PublicTrade.timeCreated
///       -> Repro_PublicTrade.timeCreated (reads from FlatBuffers Table)
///       -> Repro_Timestamp.nanosecondsSinceUnixEpoch
///       -> Timestamp.init(_: Repro_Timestamp)
///
/// fully inlines under `-O`.
public struct PublicTrade: Sendable {
    // `Repro_PublicTrade` is not Sendable because it wraps a FlatBuffers
    // `Table` / `ByteBuffer`. Production `PublicTrade` in package-data-model
    // does the same thing via `nonisolated(unsafe) var _storage: any _PublicTrade`.
    @usableFromInline
    nonisolated(unsafe) let _flatBuffersObject: Repro_PublicTrade

    @inlinable
    init(_ fb: Repro_PublicTrade) {
        self._flatBuffersObject = fb
    }

    /// The hot accessor under study. The caller in the benchmark reads this
    /// in a tight loop.
    @inlinable
    public var timeCreated: Timestamp {
        Timestamp(_flatBuffersObject.timeCreated)
    }
}

extension PublicTrade {
    /// Builds a FlatBuffers buffer containing a `PublicTrade` with the given
    /// timestamp and returns both the backing buffer (which must be kept alive
    /// for as long as the wrapper is used) and the `PublicTrade` wrapper.
    public static func make(nanoseconds: UInt64) -> (ByteBuffer, PublicTrade) {
        var fbb = FlatBufferBuilder()
        let ts = Repro_Timestamp(nanosecondsSinceUnixEpoch: nanoseconds)
        let offset = Repro_PublicTrade.createPublicTrade(&fbb, timeCreated: ts)
        fbb.finish(offset: offset)
        var buffer = fbb.sizedBuffer
        let reader: Repro_PublicTrade = getRoot(byteBuffer: &buffer)
        return (buffer, PublicTrade(reader))
    }
}
