import XCTest
import Distributed
@testable import DistributedSystem

actor TestActor: Endpoint {
    typealias ActorSystem = DistributedSystem

    init(in: DistributedSystem) {
        print("TestActor.init()")
    }
}

distributed actor TestDistributedActor: Endpoint {
    typealias ActorSystem = DistributedSystem
    
    init(in: DistributedSystem) {
        print("TestDistributedActor.init()")
    }
}

final class DistributedSystemTests: XCTestCase {
    func test1() async throws {
        let distributedSystem = DistributedSystem()
        let _: TestActor = distributedSystem.createActor()
        let _: TestDistributedActor = distributedSystem.createActor()
    }
}
