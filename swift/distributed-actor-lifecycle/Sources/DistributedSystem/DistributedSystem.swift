import Distributed

public struct RemoteCallEncoder: DistributedTargetInvocationEncoder {

    public typealias SerializationRequirement = Codable
    public var target: RemoteCallTarget?

    init() {}

    public mutating func recordArgument(_ argument: RemoteCallArgument<some Codable>) throws {
        print("recordArgument")
    }

    public mutating func recordReturnType(_: (some Codable).Type) throws {
    }

    public mutating func recordGenericSubstitution(_ type: (some Any).Type) throws {
    }

    public mutating func recordErrorType(_: (some Error).Type) throws {
    }

    public mutating func doneRecording() throws {
    }
}

public struct RemoteCallDecoder: DistributedTargetInvocationDecoder, Decoder {
    public typealias SerializationRequirement = Codable

    public var codingPath = [CodingKey]()
    public var userInfo = [CodingUserInfoKey : Any]()

    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        fatalError("not implemented")
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("not implemented")
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError("not implemented")
    }

    public mutating func decodeNextArgument<Argument: SerializationRequirement>() throws -> Argument {
        return try Argument(from: self)
    }

    public mutating func decodeGenericSubstitutions() throws -> [Any.Type] {
        // Generics are not supported in this version
        []
    }

    public mutating func decodeErrorType() throws -> Any.Type? {
        // Throwing error is not supported in this version
        nil
    }

    public mutating func decodeReturnType() throws -> Any.Type? {
        // Return type is not supported in this version
        nil
    }
}

public struct RemoteCallResultHandler: DistributedTargetInvocationResultHandler {
    public typealias SerializationRequirement = Codable

    public func onReturn(value _: some SerializationRequirement) async throws {
        fatalError("not implemented")
    }

    public func onReturnVoid() async throws {
        fatalError("not implemented")
    }

    public func onThrow(error: some Error) async throws {
        fatalError("not implemented")
    }
}

public protocol DistributedActorFactory {
    func makeActor<Actor>(_ actorSystem: DistributedSystem) -> Actor
}

public class DistributedSystem: DistributedActorSystem, @unchecked Sendable {
    public typealias ActorID = String
    public typealias InvocationEncoder = RemoteCallEncoder
    public typealias InvocationDecoder = RemoteCallDecoder
    public typealias ResultHandler = RemoteCallResultHandler
    public typealias SerializationRequirement = Codable

    private let actorFactory: DistributedActorFactory

    public static let localActorID = "LOCAL"
    public static let remoteActorID = "REMOTE"

    public init(_ actorFactory: DistributedActorFactory) {
        self.actorFactory = actorFactory
        print("DistributedSystem.init")
    }

    deinit {
        print("DistributedSystem.deinit")
    }

    public func assignID<Actor>(
        _ actorType: Actor.Type
    ) -> ActorID where Actor: DistributedActor, ActorID == Actor.ID {
        // will be called only for the actor supposed to run locally
        let id = Self.localActorID
        print("DistributedSystem.assign<\(Actor.self)>: '\(id)'")
        return id
    }

    public func resolve<Actor>(
        id: ActorID, as _: Actor.Type
    ) throws -> Actor? where Actor: DistributedActor, ActorID == Actor.ID {
        print("DistributedSystem.resolve<\(Actor.self)>: '\(id)'")
        if id == Self.localActorID {
            return actorFactory.makeActor(self)
        } else if id == Self.remoteActorID {
            // return nil indicating the proxy should be created
            return nil
        } else {
            fatalError("should not happen")
        }
    }

    public func actorReady<Actor>(
        _ actor: Actor
    ) where Actor: DistributedActor, ActorID == Actor.ID {
        print("DistributedSystem.actorReady<\(Actor.self)>: '\(actor.id)'")
    }

    public func resignID(_ id: ActorID) {
        print("DistributedSystem.resign: '\(id)'")
    }

    public func makeInvocationEncoder() -> RemoteCallEncoder {
        RemoteCallEncoder()
    }

    public func remoteCall<Actor, Err, Result>(
        on _: Actor,
        target _: RemoteCallTarget,
        invocation _: inout InvocationEncoder,
        throwing _: Err.Type,
        returning _: Result.Type
    ) async throws -> Result where Actor: DistributedActor, Actor.ID == ActorID, Err: Error, Result: SerializationRequirement {
        fatalError("not implemented")
    }

    public func remoteCallVoid<Actor, Err>(
        on actor: Actor,
        target: RemoteCallTarget,
        invocation: inout InvocationEncoder,
        throwing _: Err.Type
    ) async throws where Actor: DistributedActor, Actor.ID == ActorID, Err: Error {
        print("DistributedSystem.remoteCallVoid<\(Actor.self)>: '\(actor.id)'")
    }

    public func performRemoteCall() async throws {
    }
}
