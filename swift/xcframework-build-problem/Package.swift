// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcframework-test",
    platforms: [
        .macOS(.v14)
    ],
    products: [],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "XCFrameworkTest",
            dependencies: ["DistributedSystemConformance"]
        ),
        .binaryTarget(
            name: "DistributedSystemConformance",
            path: "DistributedSystemConformance.xcframework"
         )
    ]
)
