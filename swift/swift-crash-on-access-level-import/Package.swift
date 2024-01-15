// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "process",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "Process",
            targets: ["Process"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.2.2")),
        .package(url: "https://github.com/apple/swift-system", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.0.0"),
        .package(name: "OrdoPublic", path: "Local/OrdoPublic"),
        .package(name: "OrdoInternals", path: "Local/OrdoPublic/Local/OrdoInternals"),
        .package(name: "OrdoEssentials", path: "Local/OrdoPublic/Local/OrdoEssentials"),
        
    ],
    targets: [
        .executableTarget(
            name: "Process",
            dependencies: [
                .product(name: "OrdoEssentials", package: "OrdoEssentials"),
                .product(name: "OrdoInternals", package: "OrdoInternals"),
                .product(name: "OrdoPublic", package: "OrdoPublic"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "Logging", package: "swift-log"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport"),
            ]
        ),
    ]
)
