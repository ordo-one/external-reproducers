import Benchmark
import Cursor

class A
{
    init() {}
}
class B
{
    init() {}
}

let benchmarks:@Sendable () -> () =
{
    Benchmark.init("Tuple",
        configuration: .init(metrics: BenchmarkMetric.default,
        maxDuration: .seconds(10)))
    {
        let ca:Cursor1<Int, A> = .init(key: 1, value: .init(), count: $0.scaledIterations.count)
        for (key, value):(Int, A) in ca
        {
            blackHole((key, value))
        }
    }

    Benchmark.init("Pair",
        configuration: .init(metrics: BenchmarkMetric.default,
        maxDuration: .seconds(10)))
    {
        let cb:Cursor2<Int, B> = .init(key: 1, value: .init(), count: $0.scaledIterations.count)
        for try next:Cursor2<Int, B>.Pair in cb
        {
            blackHole(next)
        }
    }
}
