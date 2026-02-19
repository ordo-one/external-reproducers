// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [
        .macOS(.v26),
    ],
    dependencies: [
        .package(path: "../Local/Public"),
        .package(url: "https://github.com/ordo-one/package-benchmark.git", from: "1.27.0"),
    ],
    targets: [
        .executableTarget(
            name: "StructPlacement",
            dependencies: [
                .product(name: "Public", package: "Public"),
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/StructPlacement",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),
    ]
)
