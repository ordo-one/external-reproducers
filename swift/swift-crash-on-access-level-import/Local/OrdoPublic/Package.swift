// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OrdoPublic",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "OrdoPublic",
            type: .dynamic,
            targets: ["OrdoPublic"]
        )
    ],
    dependencies: [
        .package(name: "OrdoEssentials", path: "Local/OrdoEssentials"),
        .package(name: "OrdoInternals", path: "Local/OrdoInternals"),
    ],
    targets: [
        .target(
            name: "OrdoPublic",
            dependencies: [
                .product(name: "OrdoEssentials", package: "OrdoEssentials"),
                .product(name: "OrdoInternals", package: "OrdoInternals"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport"),
                .unsafeFlags(["-enable-library-evolution", "-emit-module-interface"])
            ]
        )
    ]
)
