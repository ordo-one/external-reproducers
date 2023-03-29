// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "elide-some",
    platforms: [.macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "elide-some",
            targets: ["elide-some"]),
    ],
    dependencies: [
        //        .package(url: "https://github.com/ordo-one/package-benchmark", branch: "main"),
         .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "1.4.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "elide-some"),
        .testTarget(
            name: "elide-someTests",
            dependencies: ["elide-some"]),
    ]
)

// Benchmark of ElideSome
package.targets += [
    .executableTarget(
        name: "ElideSome",
        dependencies: [
            .product(name: "Benchmark", package: "package-benchmark"),
            .product(name: "BenchmarkPlugin", package: "package-benchmark")
        ],
        path: "Benchmarks/ElideSome"
    ),
]
