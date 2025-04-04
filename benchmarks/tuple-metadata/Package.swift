// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package:Package = .init(
    name: "tuple-metadata",
    platforms: [.macOS(.v13)],
    products: [
    ],
    dependencies: [
         .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.29.2")),
    ],
    targets: [
        .target(
            name: "Cursor",
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"]),
            ]
        ),
        .executableTarget(
            name: "CursorBenchmark",
            dependencies: [
                .target(name: "Cursor"),
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/CursorBenchmark",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),
    ]
)
