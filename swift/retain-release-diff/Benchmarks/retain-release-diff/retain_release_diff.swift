import Benchmark

let benchmarks = {
    func concurrentWork(tasks: Int) async {
        _ = await withTaskGroup(of: Void.self, returning: Void.self, body: { taskGroup in
            for _ in 0 ..< tasks {
                taskGroup.addTask {
                }
            }

            for await _ in taskGroup {}
        })
    }

    Benchmark("Retain/release deviation",
              configuration: .init(metrics: BenchmarkMetric.arc, maxDuration: .seconds(3))) { _ in
        await concurrentWork(tasks: 789)
    }
}
