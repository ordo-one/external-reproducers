import Distributed
import Implementation
import Protocols

// Crashes under -O: the existential conversion makes the SIL linker deserialize the witness table.
public func makeService(system: LocalTestingDistributedActorSystem) -> any Service {
    ServiceActor(actorSystem: system)
}
