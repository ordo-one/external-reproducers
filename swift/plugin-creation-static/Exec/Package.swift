// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Exec",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .executable(
            name: "Exec",
            targets: ["Exec"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.2.2")),
        .package(url: "https://github.com/ordo-one/package-bundle-manager", .upToNextMajor(from: "2.0.0")),
        .package(name: "Api", path: "../Api")
    ],
    targets: [
        .executableTarget(
            name: "Exec",
            dependencies: [
                "Api",
                .product(name: "BundleManager", package: "package-bundle-manager"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        )
    ]
)
