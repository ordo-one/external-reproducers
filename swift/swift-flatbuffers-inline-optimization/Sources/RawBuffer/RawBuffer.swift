// FBB-like infrastructure types — analog of the `flatbuffers` Swift package
// types `ByteBuffer`, `Table`, and `Struct`. Lives in its own module so that
// callers in another module (`RawBytes`) cross a real module boundary, just
// like generated FB code crossing into the `flatbuffers` package.
//
// Inline annotations match the FB originals exactly:
//
// - `RawByteBuffer.read`        @inline(__always) (matches `ByteBuffer.read`)
// - `Reader.readBuffer`         no annotation     (matches `Table.readBuffer`)
// - `Reader.directRead`         no annotation     (matches `Table.directRead`)
// - `RawStruct.readBuffer`      no annotation     (matches `Struct.readBuffer`)
//
// None of the public APIs here are `@inlinable`, exactly like FB. That means
// callers in another module can NOT inline through them — same constraint
// the production FB code lives under.

// --- ByteBuffer analog ------------------------------------------------------

@frozen
public struct RawByteBuffer {
    /// Container that owns the buffer's heap memory. Existence as a class
    /// is significant: `_storage.memory` requires a class-field load on
    /// every `read<T>` call.
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
    /// only `@inline(__always)` in the chain. Note: NOT `@inlinable`, so the
    /// hint only applies to same-module callers — cross-module callers
    /// (`RawBytes`) cannot inline this, exactly like FB.
    @inline(__always)
    public func read<T>(def: T.Type, position: Int) -> T {
        if allowReadingUnalignedBuffers {
            return _storage.memory.advanced(by: position).loadUnaligned(as: T.self)
        }
        return _storage.memory.advanced(by: position).load(as: T.self)
    }
}

// --- Table analog -----------------------------------------------------------

@frozen
public struct Reader {
    public private(set) var bb: RawByteBuffer
    public private(set) var position: Int32

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

@frozen
public struct RawStruct {
    public private(set) var bb: RawByteBuffer
    public private(set) var position: Int32

    public init(bb: RawByteBuffer, position: Int32 = 0) {
        self.bb = bb
        self.position = position
    }

    public func readBuffer<T>(of type: T.Type, at o: Int32) -> T {
        let r = bb.read(def: T.self, position: Int(o + position))
        return r
    }
}
