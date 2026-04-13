// "Fakely generated" types + the public wrapper/bridge.
//
// Mirrors what flatc would emit (`Repro_Timestamp`, `Repro_PublicTrade`)
// plus the hand-written wrapper (`FBBTable`) and bridge (`Timestamp`) that
// would normally live alongside the generated code in the same module.
//
// Lives in module `RawBytes`. The FBB-like infrastructure types this code
// uses (`RawByteBuffer`, `Reader`, `RawStruct`) live in the sibling
// `RawBuffer` module — so calls to `Reader.readBuffer` etc. cross a real
// module boundary, exactly like generated FB code calling into the
// `flatbuffers` package.
//
// Inline annotations on this side preserve the FB shape:
//
//   RawBytesTable.timestamp                          (@inlinable, like FBBTable.timeCreated)
//     -> BufferReader.timestamp                      (plain public, like Repro_PublicTrade.timeCreated)
//       -> Reader.readBuffer<RawTimestamp>(of:at:)   (in RawBuffer module — cross-module call)
//         ...
//     -> RawBytesTimestamp.init(_:)                  (@inlinable bridge, like Timestamp.init(_:))

internal import RawBuffer

// --- "FlatBuffers struct" analog --------------------------------------------
// Mirrors generated `Repro_Timestamp`. `_nanosecondsSinceUnixEpoch` is
// `private` (matching the generated code, NOT `@usableFromInline`).
// `init(_ bb:, o: Int32)` goes through `RawStruct` — kept for parity even
// though the hot path bypasses it via `loadUnaligned(as: RawTimestamp.self)`.

public struct RawTimestamp {
    private var _nanosecondsSinceUnixEpoch: UInt64

    internal init(_ bb: RawByteBuffer, o: Int32) {
        let _accessor = RawStruct(bb: bb, position: o)
        _nanosecondsSinceUnixEpoch = _accessor.readBuffer(of: UInt64.self, at: 0)
    }

    public init(nanosecondsSinceUnixEpoch: UInt64) {
        _nanosecondsSinceUnixEpoch = nanosecondsSinceUnixEpoch
    }

    public var nanosecondsSinceUnixEpoch: UInt64 { _nanosecondsSinceUnixEpoch }
}

// --- Generated table-reader analog ------------------------------------------
// Mirrors generated `Repro_PublicTrade`. `_accessor` is `private var` like
// the generated code. Accessor is plain public — no `@inline*`, no
// `@inlinable`. Hardcoded `at: 0` instead of `_accessor.offset(VTOFFSET...)`.

public struct BufferReader {
    private var _accessor: Reader

    internal init(_ bb: RawByteBuffer, o: Int32) {
        _accessor = Reader(bb: bb, position: o)
    }

    public var timestamp: RawTimestamp {
        _accessor.readBuffer(of: RawTimestamp.self, at: 0)
    }
}

// --- Public bridge type -----------------------------------------------------
// Mirrors public `Timestamp` from OrdoEssentials.

public struct RawBytesTimestamp: Sendable, Equatable, Hashable {
    public var nanosecondsSinceUnixEpoch: UInt64

    @inlinable
    public init(nanosecondsSinceUnixEpoch: UInt64) {
        self.nanosecondsSinceUnixEpoch = nanosecondsSinceUnixEpoch
    }

    @inlinable
    init(_ raw: RawTimestamp) {
        self.init(nanosecondsSinceUnixEpoch: raw.nanosecondsSinceUnixEpoch)
    }
}

// --- Public wrapper ---------------------------------------------------------
// Mirrors `FBBTable` — direct storage, no existential.

public struct RawBytesTable {
    let _reader: BufferReader

    init(_ reader: BufferReader) {
        self._reader = reader
    }

    /// Hot accessor under study.
    public var timestamp: RawBytesTimestamp {
        RawBytesTimestamp(_reader.timestamp)
    }
}

extension RawBytesTable {
    /// Mirrors `FBBTable.make(nanoseconds:)`. The 8-byte heap allocation is
    /// owned by `RawByteBuffer.Storage`, so no separate buffer needs to be
    /// returned to keep memory alive.
    public static func make(nanoseconds: UInt64) -> RawBytesTable {
        var bytes = [UInt8](repeating: 0, count: MemoryLayout<UInt64>.size)
        bytes.withUnsafeMutableBytes {
            $0.storeBytes(of: nanoseconds, as: UInt64.self)
        }
        let bb = RawByteBuffer(bytes: bytes)
        let reader = BufferReader(bb, o: 0)
        return RawBytesTable(reader)
    }
}
