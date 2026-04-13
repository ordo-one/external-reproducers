// Skeleton mirroring the full FlatBuffers read chain, but with no FlatBuffers
// dependency. Same call layers and same `@inline*` annotations (or absence)
// as the FB types in
// `.build/checkouts/flatbuffers/swift/Sources/FlatBuffers/`:
//
//   RawBytesTable.timestamp                          (@inlinable, like FBBTable.timeCreated)
//     -> BufferReader.timestamp                      (plain public, like Repro_PublicTrade.timeCreated)
//       -> Reader.readBuffer<RawTimestamp>(of:at:)   (plain public, like Table.readBuffer)
//         -> Reader.directRead<RawTimestamp>(of:offset:) (plain public, like Table.directRead)
//           -> RawByteBuffer.read<RawTimestamp>(def:position:) (@inline(__always), like ByteBuffer.read)
//             -> _storage.memory.advanced(by:).loadUnaligned(as: RawTimestamp.self)
//     -> RawBytesTimestamp.init(_:)                  (@inlinable bridge, like Timestamp.init(_:))
//
// Only allowed simplification: the final bytes contain only the timestamp,
// so `BufferReader.timestamp` reads at hardcoded offset 0 (no vtable lookup
// like the generated `Table.offset(VTOFFSET.timeCreated.v)`).

// --- ByteBuffer analog ------------------------------------------------------
// Mirrors `@frozen public struct ByteBuffer` including the nested
// `@usableFromInline final class Storage` that introduces the heap
// indirection on every read (`_storage.memory` is a class field load).

struct RawByteBuffer {
    /// Container that owns the buffer's heap memory. Existence as a class
    /// is significant: `_storage.memory` requires a class-field load on
    /// every `read<T>` call, which is the suspected inline-blocker.
    @usableFromInline
    final class Storage {
        @usableFromInline var memory: UnsafeMutableRawPointer
        @usableFromInline var capacity: Int
        private let unowned: Bool

        @usableFromInline
        init(count: Int, alignment: Int) {
            memory = UnsafeMutableRawPointer.allocate(
                byteCount: count,
                alignment: alignment)
            capacity = count
            unowned = false
        }

        deinit {
            if !unowned {
                memory.deallocate()
            }
        }

        @usableFromInline
        func copy(from ptr: UnsafeRawPointer, count: Int) {
            memory.copyMemory(from: ptr, byteCount: count)
        }
    }

    @usableFromInline var _storage: Storage

    public let allowReadingUnalignedBuffers: Bool

    public var memory: UnsafeMutableRawPointer { _storage.memory }
    public var capacity: Int { _storage.capacity }

    public init(bytes: [UInt8], allowReadingUnalignedBuffers: Bool = true) {
        var b = bytes
        self._storage = Storage(count: bytes.count, alignment: 1)
        self.allowReadingUnalignedBuffers = allowReadingUnalignedBuffers
        b.withUnsafeMutableBytes { bufferPointer in
            self._storage.copy(from: bufferPointer.baseAddress!, count: bytes.count)
        }
    }

    /// Body identical to `ByteBuffer.read` (`ByteBuffer.swift:454-460`). The
    /// only `@inline(__always)` in the chain.
    @inline(__always)
    public func read<T>(def: T.Type, position: Int) -> T {
        if allowReadingUnalignedBuffers {
            return _storage.memory.advanced(by: position).loadUnaligned(as: T.self)
        }
        return _storage.memory.advanced(by: position).load(as: T.self)
    }
}

// --- Table analog -----------------------------------------------------------
// Mirrors `@frozen public struct Table`. `readBuffer` and `directRead` are
// plain `public func` with NO inline annotation — exactly as in FB.

internal struct Reader {
    internal var bb: RawByteBuffer
    internal var position: Int32

    public init(bb: RawByteBuffer, position: Int32 = 0) {
        self.bb = bb
        self.position = position
    }

    public func readBuffer<T>(of type: T.Type, at o: Int32) -> T {
        directRead(of: T.self, offset: o + position)
    }

    public func directRead<T>(of type: T.Type, offset o: Int32) -> T {
        let r = bb.read(def: T.self, position: Int(o))
        return r
    }
}

// --- Struct analog ----------------------------------------------------------
// Mirrors `@frozen public struct Struct`. Single-step `readBuffer` (no
// `directRead`), plain `public func`. Dead on the hot path — present only so
// `RawTimestamp.init(_:o:)` mirrors the generated init faithfully.

struct RawStruct {
    internal private(set) var bb: RawByteBuffer
    internal private(set) var position: Int32

    public init(bb: RawByteBuffer, position: Int32 = 0) {
        self.bb = bb
        self.position = position
    }

    public func readBuffer<T>(of type: T.Type, at o: Int32) -> T {
        let r = bb.read(def: T.self, position: Int(o + position))
        return r
    }
}

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
// Mirrors `FBBTable` — direct storage, no existential. `nonisolated(unsafe)`
// because `BufferReader` (transitively) holds the class `Storage`, exactly
// the same situation as `FBBTable._flatBuffersObject`.

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
