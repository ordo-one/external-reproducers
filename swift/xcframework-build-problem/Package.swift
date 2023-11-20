// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcframework-test",
    platforms: [
        .macOS(.v14)
    ],
    products: [],
    dependencies: [
        // .package(url: "https://github.com/ordo-one/package-distributed-system-conformance.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "XCFrameworkTest",
            dependencies: [
                "DistributedSystemConformance"
                // .product(name: "DistributedSystemConformance", package: "package-distributed-system-conformance")
            ]
        ),
        .binaryTarget(
            name: "DistributedSystemConformance",
            path: "DistributedSystemConformance.xcframework"
         )
    ]
)
