// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-62-runtime-crash",
    platforms: [
        .macOS(.v26)
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "base"
        ),
        .target(
            name: "impl",
            dependencies: ["base"]
        ),
        .executableTarget(
            name: "swift-62-runtime-crash",
            dependencies: ["base", "impl"]
        )
    ]
)
