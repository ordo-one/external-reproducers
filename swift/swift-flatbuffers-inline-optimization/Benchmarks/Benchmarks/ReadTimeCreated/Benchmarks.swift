import Benchmark
import RawBytes

@MainActor
let benchmarks: @Sendable () -> Void = {
    Benchmark.defaultConfiguration = .init(
        metrics: [.cpuTotal, .wallClock, .throughput],
        warmupIterations: 10,
        scalingFactor: .mega
    )

    Benchmark("RawBytes: read timestamp hot loop") { benchmark in
        let trade = RawBytesTable.make(nanoseconds: 1_700_000_000_000_000_000)

        benchmark.startMeasurement()
        for _ in benchmark.scaledIterations {
            for _ in 1...20 {
                Benchmark.blackHole(trade.timestamp.nanosecondsSinceUnixEpoch)
            }
        }
        benchmark.stopMeasurement()
    }
}
