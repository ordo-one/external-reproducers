internal import OrdoInternals
import OrdoEssentials

public struct Transaction: CustomStringConvertible {

    public init(_ id: TransactionIdentifier) {
        _storage = _TransactionStruct(id: id)
    }
    
    public var id: TransactionIdentifier {
        _storage.id
    }
    
    public var time: Timestamp? {
        _storage.time
    }
    
    public var mic: MIC? {
        _storage.mic
    }
    
    public var description: String {
        "{ id = \(id), time = \(time), mic = \(mic)}"
    }
    
    public mutating func merge(_ update: TransactionUpdate) {
        _storage.merge(update._storage)
    }
    
    public func makeUpdate() -> TransactionUpdate {
        TransactionUpdate(id)
    }
    
    public init?(storage: _TransactionStorage) {
        guard let storage = storage as? _Transaction else {
            return nil
        }
        guard storage is _TransactionStruct || storage is _TransactionBuffer else {
            return nil
        }
        _storage = storage
    }
    
    public var storage: _TransactionStorage {
        _storage
    }
    
    var _storage: _Transaction
}

public struct TransactionUpdate: CustomStringConvertible {
    public init(_ id: TransactionIdentifier) {
        _storage = _TransactionUpdateStruct(id: id)
    }
    
    public var id: TransactionIdentifier {
        _storage.id
    }
    
    public var time: Timestamp? {
        get {
            _storage.time
        }
        set {
            _storage.time = newValue
        }
    }
    
    public var mic: MIC? {
        get {
            _storage.mic
        }
        set {
            _storage.mic = newValue
        }
    }
    
    public var description: String {
        "{ id = \(id), time = \(time), mic = \(mic)}"
    }
    
    public init?(storage: _TransactionUpdateStorage) {
        guard let storage = storage as? _TransactionUpdate else {
            return nil
        }
        guard storage is _TransactionUpdateStruct || storage is _TransactionUpdateBuffer else {
            return nil
        }
        _storage = storage
    }
    
    public var storage: _TransactionUpdateStorage {
        _storage
    }
    
    var _storage: _TransactionUpdate
}
