import Benchmark
import Reproducer

@MainActor
let benchmarks: @Sendable () -> Void = {
    Benchmark.defaultConfiguration = .init(
        metrics: [.cpuTotal, .wallClock, .throughput],
        warmupIterations: 10,
        scalingFactor: .mega
    )

    Benchmark("read timeCreated hot loop") { benchmark in
        let (buffer, trade) = PublicTrade.make(nanoseconds: 1_700_000_000_000_000_000)
        // Hold on to the FlatBuffers buffer so the reader's pointer stays valid
        // for the duration of the hot loop.
        _ = buffer

        benchmark.startMeasurement()
        for _ in benchmark.scaledIterations {
            for _ in 1...20 {
                Benchmark.blackHole(trade.timeCreated.nanosecondsSinceUnixEpoch)
            }
        }
        benchmark.stopMeasurement()
    }
}
