import Benchmark
import ThrowingCallPerf

let benchmarks: @Sendable () -> Void = {
    Benchmark("typedThrowsGenericError") { benchmark in
        var value: Int = 42
        try withUnsafeBytes(of: &value) { buffer in
            for _ in benchmark.scaledIterations {
                let value = try Int(typedThrowsGenericError: buffer)
                blackHole(value)
            }
        }
    }

    Benchmark("typedThrowsNonGenericError") { benchmark in
        var value: Int = 43
        try withUnsafeBytes(of: &value) { buffer in
            for _ in benchmark.scaledIterations {
                let value = try Int(typedThrowsNonGenericError: buffer)
                blackHole(value)
            }
        }
    }

    Benchmark("nonTypedThrowsGenericError") { benchmark in
        var value: Int = 44
        try withUnsafeBytes(of: &value) { buffer in
            for _ in benchmark.scaledIterations {
                let value = try Int(nonTypedThrowsGenericError: buffer)
                blackHole(value)
            }
        }
    }

    Benchmark("nonTypedThrowsNonGenericError") { benchmark in
        var value: Int = 45
        try withUnsafeBytes(of: &value) { buffer in
            for _ in benchmark.scaledIterations {
                let value = try Int(nonTypedThrowsNonGenericError: buffer)
                blackHole(value)
            }
        }
    }
}
