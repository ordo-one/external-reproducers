import base
import Foundation
import Synchronization

private class CacheInstanceBase<Object: Identifiable>: @unchecked Sendable {
    let predicate: Predicate<Object>?

    init(predicate: Predicate<Object>) {
        self.predicate = predicate
    }
}

private final class Impl<Object: Marker1 & Marker2 & Identifiable & Sendable>: Proto1 where Object.ID: Sendable & Hashable {
    typealias ObjectEntry = Object
    private struct State: Sendable {
        var predicate: Predicate<Object>?
        var instance: CacheInstanceBase<Object>?
        var array: [Object.ID: Object] = [:]

        func entries() throws -> any Sequence<Object> {
            guard let predicate = self.instance?.predicate ?? predicate else {
                return []
            }
            let snapshot = try self.array.values.compactMap {
                if try predicate.evaluate($0) {
                    return $0
                } else {
                    return nil
                }
            }
            return snapshot
        }
    }

    private let state: Mutex<State>

    init(predicate: Predicate<Object>) {
        state = .init(.init(predicate: predicate, instance: .init(predicate: predicate)))
    }

    func entries() throws -> any Sequence<Object> {
        try state.withLock {
            try $0.entries()
        }
    }

    var predicate: Predicate<Object> { state.withLock { $0.instance?.predicate ?? $0.predicate ?? .true } }
}

public func make<Object: Marker1 & Marker2 & Identifiable & Sendable>(predicate: Predicate<Object>) -> any Proto1<Object> where Object.ID: Sendable & Hashable {
    return Impl<Object>(predicate: predicate)
}
