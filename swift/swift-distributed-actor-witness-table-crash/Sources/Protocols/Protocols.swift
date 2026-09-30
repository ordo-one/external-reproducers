import Distributed

public protocol Service: DistributedActor where ActorSystem == LocalTestingDistributedActorSystem {
    distributed func ping() async throws
}
