// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "async-algorithms-evolution",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "TestLib",
            type: .dynamic,
            targets: ["TestLib"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/FranzBusch/swift-async-algorithms.git", branch: "fb-async-backpressured-stream")
    ],
    targets: [
        .target(
            name: "TestLib",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ]
        )
    ]
)

