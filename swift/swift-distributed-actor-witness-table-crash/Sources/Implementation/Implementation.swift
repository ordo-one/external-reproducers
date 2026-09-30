import Distributed
import Protocols

public distributed actor ServiceActor: Service {
    public typealias ActorSystem = LocalTestingDistributedActorSystem

    public init(actorSystem: LocalTestingDistributedActorSystem) {
        self.actorSystem = actorSystem
    }

    public distributed func ping() async throws {}
}
