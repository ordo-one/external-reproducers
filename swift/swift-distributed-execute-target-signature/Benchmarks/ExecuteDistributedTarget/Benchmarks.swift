// Per received distributed call, for each target shape, the runtime’s `executeDistributedTarget` beside a
// hand-written dispatch of the same call, as package-benchmark benchmarks:
//
//   executeDistributedTarget <target>   what an actor system does on every received call today
//   handWritten <target>                a dictionary lookup on the identifier, the arguments decoded in
//                                       declaration order and the local call through the distributed thunk;
//                                       an optimised lower bound (see `DirectPath`)
//
// Each sample is a thousand calls (`scalingFactor: .kilo`), and every figure is per call: retired
// instructions (`proc_pid_rusage`, process-wide), `malloc` calls (counted by package-benchmark’s malloc
// interposer, which replaces libmalloc’s entry points through dyld interposing for the whole process) and
// wall clock. The counters and the wall clock are taken in separate runs (`--metric`), since the malloc
// counting is on the allocation path while it is enabled. The warm-up iterations take whatever the runtime
// initialises lazily on the first calls out of the samples.

import Benchmark
import Dispatch
import Distributed

let benchmarks: @Sendable () -> Void = {
    Benchmark.defaultConfiguration = .init(
        metrics: [.instructions, .mallocCountTotal, .wallClock],
        timeUnits: .nanoseconds,
        units: [.instructions: .count, .mallocCountTotal: .count],
        warmupIterations: 2,
        scalingFactor: .kilo,
        maxDuration: .seconds(120),
        maxIterations: 500
    )

    let system = TinyActorSystem()
    let worker = Worker(actorSystem: system)
    let handler = TinyResultHandler()
    let names = Fixture.names
    let table = DirectPath.Table(names)

    for target in Target.allCases {
        let identifier = names[target]
        let remoteTarget = RemoteCallTarget(identifier)

        Benchmark("executeDistributedTarget \(target.rawValue)") { benchmark in
            for _ in benchmark.scaledIterations {
                var decoder = TinyInvocationDecoder()
                try await RuntimePath.execute(system, on: worker, target: remoteTarget,
                                              decoder: &decoder, handler: handler)
            }
        }

        Benchmark("handWritten \(target.rawValue)") { benchmark in
            for _ in benchmark.scaledIterations {
                var decoder = TinyInvocationDecoder()
                try await DirectPath.execute(table, on: worker, identifier: identifier,
                                             decoder: &decoder, handler: handler)
            }
        }
    }
}

/// The mangled target names, captured from the runtime once, before the benchmarks are registered (the
/// registration closure is synchronous, the capture goes through `remoteCall`).
enum Fixture {
    static let names: TargetNames = {
        let semaphore = DispatchSemaphore(value: 0)
        nonisolated(unsafe) var captured: TargetNames?
        Task.detached {
            captured = try! await TargetNames.capture()
            semaphore.signal()
        }
        semaphore.wait()
        return captured!
    }()
}
