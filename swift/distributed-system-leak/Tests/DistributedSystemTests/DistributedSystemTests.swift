import XCTest
import Distributed
@testable import DistributedSystem

class ArgumentTypeSentinel {
    init() { print("init: \(Unmanaged.passUnretained(self).toOpaque())") }
    deinit { print("deinit: \(Unmanaged.passUnretained(self).toOpaque())") }
}

struct ArgumentType: Codable {
    let sentinel: ArgumentTypeSentinel
    let value: Int
    
    init(_ value: Int) {
        self.sentinel = ArgumentTypeSentinel()
        self.value = value
    }

    init(from decoder: Decoder) throws {
        self.sentinel = ArgumentTypeSentinel()
        self.value = 100
    }

    func encode(to encoder: Encoder) throws {
        print("ArgumentType.encode")
    }
}

distributed actor TestActor {
    public typealias ActorSystem = DistributedSystem
    
    public distributed func testFunc(arg: ArgumentType) {
        print("value=\(arg.value)")
    }
}

final class DistributedSystemTests: XCTestCase {
    func test1() async throws {
        let distributedSystem = DistributedSystem()
        let _ = TestActor(actorSystem: distributedSystem)
        let testActorResolved = try TestActor.resolve(id: 1, using: distributedSystem)
        let arg = ArgumentType(100)
        try await testActorResolved.testFunc(arg: arg)
        try await distributedSystem.performRemoteCall()
    }
}
