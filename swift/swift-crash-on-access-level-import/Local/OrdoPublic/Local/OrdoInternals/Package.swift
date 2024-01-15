// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OrdoInternals",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "OrdoInternals",
            type: .dynamic,
            targets: ["OrdoInternals"]),
    ],
    dependencies: [
        .package(name: "OrdoEssentials", path: "../OrdoEssentials")
    ],
    targets: [
        .target(
            name: "OrdoInternals",
            dependencies: [
                .product(name: "OrdoEssentials", package: "OrdoEssentials")
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport"),
                .unsafeFlags(["-enable-library-evolution", "-emit-module-interface"])
            ]
        ),
        .testTarget(
            name: "OrdoInternalsTests",
            dependencies: ["OrdoInternals"]),
    ]
)
