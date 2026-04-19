// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ids-benchmarks",
    platforms: [
        .macOS(.v15),
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark", from: "1.29.0")
    ],
    targets: [
        .executableTarget(
            name: "Benchmarks",
            dependencies: [
                "ThrowingCallPerf",
                .product(name: "Benchmark", package: "package-benchmark")
            ],
            path: "Benchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]
        ),
        .binaryTarget(
            name: "ThrowingCallPerf",
            path: "../ThrowingCallPerf-macOS.xcframework.zip"
        )
    ]
)

