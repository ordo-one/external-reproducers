import Benchmark
import Cursor

struct A
{
    var data: [UInt8]
    init() {
        data = Array(repeating: 0, count: 1024)
    }
}
struct B
{
    var data: [UInt8]
    init() {
        data = Array(repeating: 0, count: 1024)
    }
}

let benchmarks:@Sendable () -> () =
{
    Benchmark.init("Tuple",
        configuration: .init(metrics: BenchmarkMetric.default,
                             scalingFactor: .mega,
                             maxDuration: .seconds(10)))
    { benchmark in
        let operations = benchmark.scaledIterations.count
        await withTaskGroup(of: Void.self) { group in
            for _ in 0 ..< 12 {
                group.addTask {
                    let ca:Cursor1<Int, A> = .init(key: 1, value: .init(), count: operations)
                    for (key, value):(Int, A) in ca
                    {
                        blackHole((key, value))
                    }
                }
            }
        }
    }

    Benchmark.init("Pair",
        configuration: .init(metrics: BenchmarkMetric.default,
                             scalingFactor: .mega,
                             maxDuration: .seconds(10)))
    { benchmark in
        let operations = benchmark.scaledIterations.count
        await withTaskGroup(of: Void.self) { group in
            for _ in 0 ..< 12 {
                group.addTask {
                    let cb:Cursor2<Int, B> = .init(key: 1, value: .init(), count: operations)
                    for next:Cursor2<Int, B>.Pair in cb
                    {
                        blackHole(next)
                    }
                }
            }
        }
    }
}
