// The actor under test, its mangled target names, and the two ways to reach a target:
// the runtime’s `executeDistributedTarget`, and a hand-written dispatch for comparison.

import Distributed

distributed actor Worker {
    typealias ActorSystem = TinyActorSystem

    distributed func noArgs() {}
    distributed func twoInts(_ a: Int, _ b: Int) -> Int { a &+ b }
    distributed func stringAndArray(_ s: String, _ values: [Int]) -> Int { s.utf8.count &+ values.count }
    distributed func generic<T: Codable & Sendable>(_ value: T) -> T { value }
}

/// The targets, in the order they are reported.
enum Target: String, CaseIterable, Sendable {
    case noArgs, twoInts, stringAndArray, generic
}

/// The mangled names of the four distributed thunks, captured from the runtime itself: a call on a
/// remote proxy of `Worker` reaches `TinyActorSystem.remoteCall`, which records `target.identifier`.
struct TargetNames: Sendable {
    let byTarget: [Target: String]

    static func capture() async throws -> TargetNames {
        let capture = TargetCapture()
        let system = TinyActorSystem(capture: capture)
        let proxy = try Worker.resolve(id: ActorAddress(7), using: system)
        _ = try? await proxy.noArgs()
        _ = try? await proxy.twoInts(1, 2)
        _ = try? await proxy.stringAndArray("x", [1])
        _ = try? await proxy.generic(3)
        precondition(capture.identifiers.count == 4, "expected four captured targets, got \(capture.identifiers)")
        var byTarget: [Target: String] = [:]
        for (target, identifier) in zip(Target.allCases, capture.identifiers) {
            byTarget[target] = identifier
        }
        return TargetNames(byTarget: byTarget)
    }

    subscript(target: Target) -> String { byTarget[target]! }
}

/// What an actor system does on every received call today.
enum RuntimePath {
    @inline(never)
    static func execute(_ system: TinyActorSystem, on worker: Worker, target: RemoteCallTarget,
                        decoder: inout TinyInvocationDecoder, handler: TinyResultHandler) async throws {
        try await system.executeDistributedTarget(on: worker, target: target,
                                                  invocationDecoder: &decoder, handler: handler)
    }
}

/// What a system can do when it knows its own targets: one dictionary lookup on the identifier, then the
/// arguments decoded in declaration order and the local call through the distributed thunk.
///
/// An optimised lower bound, not a measure of the signature resolution alone: besides skipping the
/// resolution it decodes the arguments and delivers the result with the types known statically (no
/// result buffer, no dynamic handler invocation) and calls the generic target specialised to `Int`. The
/// saving attributable to the signature cache is the runtime path on a library built from the commit
/// before the cache against one built from the branch head, with the same flags; the shipped library
/// against the branch head is the combined effect of the branch.
enum DirectPath {
    struct Table: Sendable {
        let kinds: [String: Target]
        init(_ names: TargetNames) {
            var kinds: [String: Target] = [:]
            for (target, name) in names.byTarget { kinds[name] = target }
            self.kinds = kinds
        }
    }

    @inline(never)
    static func execute(_ table: Table, on worker: Worker, identifier: String,
                        decoder: inout TinyInvocationDecoder, handler: TinyResultHandler) async throws {
        guard let kind = table.kinds[identifier] else { fatalError("unknown target \(identifier)") }
        switch kind {
        case .noArgs:
            try await worker.noArgs()
            try await handler.onReturnVoid()
        case .twoInts:
            let a: Int = try decoder.decodeNextArgument()
            let b: Int = try decoder.decodeNextArgument()
            try await handler.onReturn(value: try await worker.twoInts(a, b))
        case .stringAndArray:
            let s: String = try decoder.decodeNextArgument()
            let values: [Int] = try decoder.decodeNextArgument()
            try await handler.onReturn(value: try await worker.stringAndArray(s, values))
        case .generic:
            // The one substitution this reproducer sends is `Int`.
            let value: Int = try decoder.decodeNextArgument()
            try await handler.onReturn(value: try await worker.generic(value))
        }
    }
}
