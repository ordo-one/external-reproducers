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
    public var codingPath: [CodingKey]
    public var userInfo: [CodingUserInfoKey : Any]
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        fatalError("not implemented")
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("not implemented")
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        fatalError("not implemented")
    }

    public typealias SerializationRequirement = Codable

    init() {
        self.codingPath = []
        self.userInfo = [:]
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

    public init() {}

    public func onReturn(value _: some SerializationRequirement) async throws {
        fatalError("not implemented")
    }

    public func onReturnVoid() async throws {
    }

    public func onThrow(error: some Error) async throws {
        fatalError("not implemented")
    }
}

public protocol Endpoint {
    associatedtype ActorSystem
    init(in: ActorSystem)
}

public class DistributedSystem: DistributedActorSystem, @unchecked Sendable {
    public typealias ActorID = Int
    public typealias InvocationEncoder = RemoteCallEncoder
    public typealias InvocationDecoder = RemoteCallDecoder
    public typealias ResultHandler = RemoteCallResultHandler
    public typealias SerializationRequirement = Codable

    private static var nextID: Int = 1
    private var actor: (any DistributedActor)?
    private var invocation: InvocationEncoder?

    public init() {
    }

    deinit {
    }

    public func createActor<T: Endpoint>(_ as: T.Type = T.self) -> T {
        return T(in: self as! T.ActorSystem)
    }

    public func assignID<Actor>(_ actorType: Actor.Type) -> ActorID
        where Actor: DistributedActor, ActorID == Actor.ID {
        let id = Self.nextID
        Self.nextID += 1
        print("assign<\(Actor.self)>: \(id)")
        return id
    }

    public func resolve<Actor>(id: ActorID, as _: Actor.Type) throws -> Actor?
        where Actor: DistributedActor, ActorID == Actor.ID {
        print("resolve<\(Actor.self)>")
        return nil
    }

    public func actorReady<Actor>(_ actor: Actor) where Actor: DistributedActor, ActorID == Actor.ID {
        print("actorReady<\(Actor.self)>: \(actor.id)")
        self.actor = actor
    }

    public func resignID(_ id: ActorID) {
        print("resign: \(id)")
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
    ) async throws -> Result
        where Actor: DistributedActor, Actor.ID == ActorID, Err: Error, Result: SerializationRequirement {
        fatalError("not implemented")
    }

    public func remoteCallVoid<Actor, Err>(
        on actor: Actor,
        target: RemoteCallTarget,
        invocation: inout InvocationEncoder,
        throwing _: Err.Type
    ) async throws
        where Actor: DistributedActor, Actor.ID == ActorID, Err: Error {
        print("remoteCallVoid")
        invocation.target = target
        self.invocation = invocation
    }
    
    public func performRemoteCall() async throws {
        guard let invocation else { fatalError("missing invocation") }
        var decoder = RemoteCallDecoder()
        let resultHandler = ResultHandler()
        try await executeDistributedTarget(on: self.actor!, target: invocation.target!, invocationDecoder: &decoder, handler: resultHandler)
    }
}
