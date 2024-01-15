@_spi(OrdoPrivate) import OrdoEssentials
import Foundation

public protocol _Transaction: _TransactionStorage {
    var id: TransactionIdentifier { get }
    var time: Timestamp? { get }
    var mic: MIC? { get }
    
    mutating func merge(_ update: _TransactionUpdate) 
}

public extension _Transaction {
    mutating func merge(_ update: _TransactionUpdateStorage) {
        if let _update = update as? _TransactionUpdate {
            print("OK: _TransactionUpdateStorage successfully casted to _TransactionUpdate")
            merge(_update)
        } else {
            print("FAIL: _TransactionUpdateStorage unsuccessfully casted to _TransactionUpdate")
        }
    }
}

public struct _TransactionStruct: _Transaction {
    public var id: TransactionIdentifier
    public var time: Timestamp?
    public var mic: MIC?
    
    public init(id: TransactionIdentifier) {
        self.id = id
    }
    
    public mutating func merge(_ update: _TransactionUpdate) {
        precondition(id == update.id, "Transaction and TransactionUpdate have different identifiers")
        time = update.time
        mic = update.mic
    }
}

public struct _TransactionBuffer: _Transaction {
    var data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public var id: TransactionIdentifier {
        data.withUnsafeBytes { bytes in
            let uint64Bytes = bytes.bindMemory(to: UInt64.self)
            return uint64Bytes[0]
        }
    }
    
    public var time: Timestamp? {
        data.withUnsafeBytes { bytes in
            let uint64Bytes = bytes.bindMemory(to: UInt64.self)
            if uint64Bytes[1] != 0 {
                return Timestamp(uint64Bytes[1])
            } else {
                return nil
            }
        }
    }
    
    public var mic: MIC? {
        data.withUnsafeBytes { bytes in
            let uint64Bytes = bytes.bindMemory(to: UInt64.self)
            if uint64Bytes[2] != 0 {
                return MIC(internal: UInt32(uint64Bytes[2]))
            } else {
                return nil
            }
        }
    }

    public mutating func merge(_ update: _TransactionUpdate) {
        precondition(id == update.id, "Transaction and TransactionUpdate have different identifiers")
        if let time = update.time {
            data.withUnsafeMutableBytes { bytes in
                let uint64Bytes = bytes.bindMemory(to: UInt64.self)
                uint64Bytes[1] = time.micro
            }
        }
        if let mic = update.mic {
            data.withUnsafeMutableBytes { bytes in
                let uint64Bytes = bytes.bindMemory(to: UInt64.self)
                uint64Bytes[2] = UInt64(mic.value)
            }
        }
    }
}

public protocol _TransactionUpdate: _TransactionUpdateStorage {
    var id: TransactionIdentifier { get }
    var time: Timestamp? { get set }
    var mic: MIC? { get set }
}

public struct _TransactionUpdateStruct: _TransactionUpdate {
    public var id: TransactionIdentifier
    public var time: Timestamp?
    public var mic: MIC?
    
    public init(id: TransactionIdentifier) {
        self.id = id
    }
}

public struct _TransactionUpdateBuffer: _TransactionUpdate {
    var data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public var id: TransactionIdentifier {
        data.withUnsafeBytes { bytes in
            let uint64Bytes = bytes.bindMemory(to: UInt64.self)
            return uint64Bytes[0]
        }
    }
    
    public var time: Timestamp? {
        get {
            data.withUnsafeBytes { bytes in
                let uint64Bytes = bytes.bindMemory(to: UInt64.self)
                return Timestamp(uint64Bytes[1])
            }
        }
        set {
            data.withUnsafeMutableBytes { bytes in
                let uint64Bytes = bytes.bindMemory(to: UInt64.self)
                if let time = newValue {
                    uint64Bytes[1] = time.micro
                } else {
                    uint64Bytes[1] = 0
                }
            }
        }
    }
    
    public var mic: MIC? {
        get {
            data.withUnsafeBytes { bytes in
                let uint64Bytes = bytes.bindMemory(to: UInt64.self)
                return MIC(internal: UInt32(uint64Bytes[2]))
            }
        }
        set {
            data.withUnsafeMutableBytes { bytes in
                let uint64Bytes = bytes.bindMemory(to: UInt64.self)
                if let mic = newValue {
                    uint64Bytes[2] = UInt64(mic.value)
                } else {
                    uint64Bytes[2] = 0
                }
            }
        }
    }
}

public func internalTestMarket(_ market: String) -> Bool {
    return Markets.hasMarket(market)
}
