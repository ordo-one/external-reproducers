// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package:Package = .init(
    name: "existential-copy",
    platforms: [.macOS(.v13)],
    products: [
    ],
    dependencies: [
         .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.29.2")),
    ],
    targets: [
        .target(
            name: "MetadataInternals",
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"]),
            ]
        ),
        .target(
            name: "Metadata",
            dependencies: [
                .target(name: "MetadataInternals"),
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"]),
            ]
        ),
        .executableTarget(
            name: "MetadataBenchmark",
            dependencies: [
                .target(name: "Metadata"),
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/MetadataBenchmark",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),
    ]
)
