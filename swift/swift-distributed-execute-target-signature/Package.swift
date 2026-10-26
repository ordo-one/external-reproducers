// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "swift-distributed-execute-target-signature",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(url: "https://github.com/ordo-one/benchmark", exact: "1.38.0"),
    ],
    targets: [
        // The minimal actor system, the actor under test and the benchmarks. One target, so that the mangled
        // names of the distributed targets keep the module name `ExecuteDistributedTarget`.
        .executableTarget(
            name: "ExecuteDistributedTarget",
            dependencies: [
                .product(name: "Benchmark", package: "benchmark"),
            ],
            path: "Benchmarks/ExecuteDistributedTarget",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "benchmark"),
            ]
        ),
    ]
)
