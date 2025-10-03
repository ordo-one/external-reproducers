import Foundation

public protocol Marker1: Sendable {}
public protocol Marker2: Sendable {}

public protocol Base<Object, ObjectEntry>: Sendable {
    associatedtype Object: Marker1 & Marker2 & Identifiable
    associatedtype ObjectEntry: Identifiable<Object.ID>

    var predicate: Predicate<Self.Object> { get }
}

public protocol Proto1<Object>: Base where Object == ObjectEntry {
}

public struct TestIdentifiable: Identifiable, Marker2, Marker1, Sendable {
    public let id: String

    init(id: String) {
        self.id = id
    }
}
