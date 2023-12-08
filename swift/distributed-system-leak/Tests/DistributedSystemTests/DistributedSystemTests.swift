import XCTest
import Distributed
@testable import DistributedSystem

class Sentinel {
    let str: String

    init(_ str: String) {
        self.str = str
        print("\(str).init: \(Unmanaged.passUnretained(self).toOpaque())")
    }

    deinit {
        print("\(str).deinit: \(Unmanaged.passUnretained(self).toOpaque())")
    }
}

struct InnerStruct1 {
    let sentinel: Sentinel
    let innerStruct2: InnerStruct2

    init() {
        self.sentinel = Sentinel("\(Self.self)")
        self.innerStruct2 = InnerStruct2()
    }
}

struct InnerStruct2 {
    let sentinel: Sentinel

    init() {
        self.sentinel = Sentinel("\(Self.self)")
    }
}

enum InnerEnum {
    case v1(String)
    case v2(InnerStruct1)
}

struct ArgumentType: Codable {
    let sentinel: Sentinel
    let value: Int
    let innerEnum: InnerEnum
    
    init(_ value: Int) {
        self.sentinel = Sentinel("ArgumentType")
        self.value = value
        self.innerEnum = .v2(InnerStruct1())
    }

    init(from decoder: Decoder) throws {
        self.sentinel = Sentinel("ArgumentType")
        self.value = 100
        self.innerEnum = .v2(InnerStruct1())
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
