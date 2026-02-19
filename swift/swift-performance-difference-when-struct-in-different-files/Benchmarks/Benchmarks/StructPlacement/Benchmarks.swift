import Benchmark
import Public

@MainActor
let benchmarks: @Sendable () -> Void = {
    Benchmark.defaultConfiguration = .init(
        metrics: [.cpuTotal, .wallClock, .throughput],
        warmupIterations: 10,
        scalingFactor: .mega
    )

    Benchmark("static value field access") {
        $0.startMeasurement()
        for _ in $0.scaledIterations {
            for _ in 1...20 {
                Benchmark.blackHole(Namespace.Definitions.publicObject.value)
            }
        }
        $0.stopMeasurement()
    }

    Benchmark("static value field access non-copyable inplace") {
        $0.startMeasurement()
        for _ in $0.scaledIterations {
            for _ in 1...20 {
                Benchmark.blackHole(Namespace.Definitions.publicObjectNonCopyableInPlace.value)
            }
        }
        $0.stopMeasurement()
    }

    Benchmark("static value field access non-copyable in other file") {
        $0.startMeasurement()
        for _ in $0.scaledIterations {
            for _ in 1...20 {
                Benchmark.blackHole(Namespace.Definitions.publicObjectNonCopyableInOtherFile.value)
            }
        }
        $0.stopMeasurement()
    }

    Benchmark("static access to frozen structure (baseline)") {
        $0.startMeasurement()
        for _ in $0.scaledIterations {
            for _ in 1...20 {
                Benchmark.blackHole(Namespace.Definitions.frozenStructure)
            }
        }
        $0.stopMeasurement()
    }

}
