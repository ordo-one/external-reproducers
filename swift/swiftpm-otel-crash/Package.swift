// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftpm-otel-crash",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "swiftpm-otel-crash",
            targets: ["swiftpm-otel-crash"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/slashmo/swift-otel", .upToNextMinor(from: "0.10.1"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "swiftpm-otel-crash"
        ),
        .testTarget(
            name: "swiftpm-otel-crashTests",
            dependencies: ["swiftpm-otel-crash"]
        ),
    ]
)
