// A minimal DistributedActorSystem whose decoder hands typed arguments straight back.
//
// Nothing is serialized. The decoder holds one typed slot per argument kind the targets use, so a
// decode is a type check and a bit cast; the handler discards the result. This keeps the system’s
// own cost near zero so that what the benchmark measures is the runtime’s `executeDistributedTarget`.

import Distributed

typealias DefaultDistributedActorSystem = TinyActorSystem

struct ActorAddress: Hashable, Sendable, Codable {
    let id: Int
    init(_ id: Int) { self.id = id }
}

/// Receives the mangled target names when a call goes through a remote proxy (see `TargetNames`).
final class TargetCapture: @unchecked Sendable {
    var identifiers: [String] = []
}

struct TinyActorSystem: DistributedActorSystem {
    typealias ActorID = ActorAddress
    typealias InvocationEncoder = TinyInvocationEncoder
    typealias InvocationDecoder = TinyInvocationDecoder
    typealias ResultHandler = TinyResultHandler
    typealias SerializationRequirement = Codable

    let capture: TargetCapture

    init(capture: TargetCapture = TargetCapture()) {
        self.capture = capture
    }

    /// Every id resolves to a remote proxy, so a call on a resolved reference reaches `remoteCall`.
    func resolve<Act>(id: ActorID, as actorType: Act.Type) throws -> Act?
    where Act: DistributedActor, Act.ID == ActorID {
        nil
    }

    func assignID<Act>(_ actorType: Act.Type) -> ActorID
    where Act: DistributedActor, Act.ID == ActorID {
        ActorAddress(1)
    }

    func actorReady<Act>(_ actor: Act) where Act: DistributedActor, Act.ID == ActorID {}

    func resignID(_ id: ActorID) {}

    func makeInvocationEncoder() -> InvocationEncoder {
        TinyInvocationEncoder()
    }

    struct Captured: Error {}

    func remoteCall<Act, Err, Res>(
        on actor: Act,
        target: RemoteCallTarget,
        invocation: inout InvocationEncoder,
        throwing: Err.Type,
        returning: Res.Type
    ) async throws -> Res
    where Act: DistributedActor, Act.ID == ActorID, Err: Error, Res: SerializationRequirement {
        capture.identifiers.append(target.identifier)
        throw Captured()
    }

    func remoteCallVoid<Act, Err>(
        on actor: Act,
        target: RemoteCallTarget,
        invocation: inout InvocationEncoder,
        throwing: Err.Type
    ) async throws
    where Act: DistributedActor, Act.ID == ActorID, Err: Error {
        capture.identifiers.append(target.identifier)
        throw Captured()
    }
}

struct TinyInvocationEncoder: DistributedTargetInvocationEncoder {
    typealias SerializationRequirement = Codable

    mutating func recordGenericSubstitution<T>(_ type: T.Type) throws {}
    mutating func recordArgument<Value: SerializationRequirement>(
        _ argument: RemoteCallArgument<Value>
    ) throws {}
    mutating func recordReturnType<R: SerializationRequirement>(_ type: R.Type) throws {}
    mutating func recordErrorType<E: Error>(_ type: E.Type) throws {}
    mutating func doneRecording() throws {}
}

/// Hands back stored values in declaration order. `Int` arguments are read from `ints`, the one `String`
/// from `string`, the one `[Int]` from `array`; the generic target’s substitution is `Int`.
struct TinyInvocationDecoder: DistributedTargetInvocationDecoder {
    typealias SerializationRequirement = Codable

    var ints: (Int, Int)
    var string: String
    var array: [Int]
    var substitutions: [Any.Type]
    var intIndex = 0

    /// The fixed values, allocated once: a literal in the initializer would be an allocation per call.
    static let defaultArray: [Int] = [1, 2, 3]
    static let intSubstitution: [Any.Type] = [Int.self]

    init(ints: (Int, Int) = (1, 2), string: String = "hello", array: [Int] = TinyInvocationDecoder.defaultArray,
                substitutions: [Any.Type] = TinyInvocationDecoder.intSubstitution) {
        self.ints = ints
        self.string = string
        self.array = array
        self.substitutions = substitutions
    }

    mutating func decodeGenericSubstitutions() throws -> [Any.Type] {
        substitutions
    }

    mutating func decodeNextArgument<Argument: SerializationRequirement>() throws -> Argument {
        if Argument.self == Int.self {
            let value = intIndex == 0 ? ints.0 : ints.1
            intIndex += 1
            return unsafeBitCast(value, to: Argument.self)
        }
        if Argument.self == String.self {
            return unsafeBitCast(string, to: Argument.self)
        }
        if Argument.self == [Int].self {
            return unsafeBitCast(array, to: Argument.self)
        }
        fatalError("unexpected argument type \(Argument.self)")
    }

    mutating func decodeErrorType() throws -> Any.Type? { nil }
    mutating func decodeReturnType() throws -> Any.Type? { nil }
}

struct TinyResultHandler: DistributedTargetInvocationResultHandler {
    typealias SerializationRequirement = Codable

    func onReturn<Success: SerializationRequirement>(value: Success) async throws {}
    func onReturnVoid() async throws {}
    func onThrow<Err: Error>(error: Err) async throws {
        fatalError("target threw: \(error)")
    }
}
