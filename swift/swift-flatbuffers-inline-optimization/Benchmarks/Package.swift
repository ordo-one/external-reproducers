// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [
        .macOS(.v26),
    ],
    dependencies: [
        .package(path: ".."),
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.27.0"),
    ],
    targets: [
        .executableTarget(
            name: "ReadTimeCreated",
            dependencies: [
                .product(name: "RawBytes", package: "swift-flatbuffers-inline-optimization"),
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/ReadTimeCreated",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),
    ]
)
