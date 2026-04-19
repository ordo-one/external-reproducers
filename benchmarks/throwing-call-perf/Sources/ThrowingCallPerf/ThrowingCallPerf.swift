public enum GenericDecodingError<T>: Error {
    case error
}

public enum DecodingError: Error {
    case error(String)
}

public protocol TestProtocol {
    init(typedThrowsGenericError buffer: UnsafeRawBufferPointer) throws
    init(typedThrowsNonGenericError buffer: UnsafeRawBufferPointer) throws
    init(nonTypedThrowsGenericError buffer: UnsafeRawBufferPointer) throws
    init(nonTypedThrowsNonGenericError buffer: UnsafeRawBufferPointer) throws
}

extension Int: TestProtocol {}

extension TestProtocol where Self: BinaryInteger & BitwiseCopyable {
    public init(typedThrowsGenericError buffer: UnsafeRawBufferPointer) throws(GenericDecodingError<Self>) {
        if buffer.count >= MemoryLayout<Self>.size {
            self = buffer.loadUnaligned(as: Self.self)
        } else {
            throw GenericDecodingError<Self>.error
        }
    }

    public init(typedThrowsNonGenericError buffer: UnsafeRawBufferPointer) throws(DecodingError) {
        if buffer.count >= MemoryLayout<Self>.size {
            self = buffer.loadUnaligned(as: Self.self)
        } else {
            throw DecodingError.error("\(Self.self)")
        }
    }

    public init(nonTypedThrowsGenericError buffer: UnsafeRawBufferPointer) throws {
        if buffer.count >= MemoryLayout<Self>.size {
            self = buffer.loadUnaligned(as: Self.self)
        } else {
            throw GenericDecodingError<Self>.error
        }
    }

    public init(nonTypedThrowsNonGenericError buffer: UnsafeRawBufferPointer) throws {
        if buffer.count >= MemoryLayout<Self>.size {
            self = buffer.loadUnaligned(as: Self.self)
        } else {
            throw DecodingError.error("\(Self.self)")
        }
    }
}
