import Benchmark
import Metadata

let metrics: [BenchmarkMetric] = [
    .wallClock,
    .cpuTotal,
    .mallocCountTotal,
    .throughput,
    .instructions,
    // .objectAllocCount,
    // .retainCount,
    // .releaseCount,
    // .retainReleaseDelta
]

let benchmarks:@Sendable () -> () = {
    Benchmark.init("x.id",
        configuration: .init(metrics: metrics,
            scalingFactor: .mega,
            maxDuration: .seconds(10))
        ) {
        for _: Int in $0.scaledIterations {
            blackHole(E.x.id)
            blackHole(E.x.a)
            blackHole(E.x.b)
        }
    }

    Benchmark.init("y.id",
        configuration: .init(metrics: metrics,
            scalingFactor: .mega,
            maxDuration: .seconds(10))
        ) {
        for _: Int in $0.scaledIterations {
            blackHole(E.y.id)
            blackHole(E.y.a)
            blackHole(E.y.b)
        }
    }

    Benchmark.init("z.id",
        configuration: .init(metrics: metrics,
            scalingFactor: .mega,
            maxDuration: .seconds(10))
        ) {
        for _: Int in $0.scaledIterations {
            blackHole(E.z.id)
            blackHole(E.z.a)
            blackHole(E.z.b)
        }
    }
}
