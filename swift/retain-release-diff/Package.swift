// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "retain-release-diff",
    platforms: [
        .macOS(.v13)
    ],
    products: [],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.3.0")),
    ],
    targets: [
        .executableTarget(
            name: "retain-release-diff",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "BenchmarkPlugin", package: "package-benchmark")
            ],
            path:"Benchmarks/retain-release-diff"),
    ]
)
