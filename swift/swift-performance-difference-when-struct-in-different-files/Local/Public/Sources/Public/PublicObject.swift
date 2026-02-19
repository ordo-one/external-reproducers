import Essentials
internal import Internal

public struct PublicObject: Sendable {
    var _storage: any _Storage

    public init(value: FrozenStructure = .init(0), description: String? = nil) {
        self._storage = StorageStruct(value)
        self._storage.description = description
    }
}

extension PublicObject {
    public var value: FrozenStructure {
        get { self._storage.value }
    }
}

@frozen public struct PublicObjectNonCopyableInOtherFile: Sendable, ~Copyable {
    let publicObject: PublicObject

    init(_ publicObject: PublicObject) {
        self.publicObject = publicObject
    }

    public var value: FrozenStructure { publicObject.value }
}
