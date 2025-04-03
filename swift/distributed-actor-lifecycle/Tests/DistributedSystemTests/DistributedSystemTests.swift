import XCTest
import Distributed
@testable import DistributedSystem

distributed actor TestActor {
    public typealias ActorSystem = DistributedSystem

    deinit {
        print("TestActor.deinit")
    }

    public distributed func foo() {
        print("TestActor.foo")
    }
}

final class DistributedSystemTests: XCTestCase {
    struct DistributedActorFactoryImpl: DistributedActorFactory {
        func makeActor<Actor>(_ actorSystem: DistributedSystem) -> Actor {
            TestActor(actorSystem: actorSystem) as! Actor
        }
    }

    func test1() async throws {
        let distributedSystem = DistributedSystem(DistributedActorFactoryImpl())

        _ = try await {
            _ = try await {
                // scope to resolve a remote distributed actor and make a call
                // supposing the distributed actor will be released at the end of the scope
                let testActor = try TestActor.resolve(id: DistributedSystem.remoteActorID, using: distributedSystem)
                try await testActor.foo()
            }()
            print("remote actor scope done")
        }()

        _ = try await {
            _ = try await {
                let testActor = try TestActor.resolve(id: DistributedSystem.localActorID, using: distributedSystem)
                try await testActor.foo()
            }()
            print("local actor scope done")
        }()

        print("test done")
    }
}
