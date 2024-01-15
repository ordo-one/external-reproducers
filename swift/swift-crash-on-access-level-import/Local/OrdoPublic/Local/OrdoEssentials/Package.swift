// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OrdoEssentials",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "OrdoEssentials",
            type: .dynamic,
            targets: ["OrdoEssentials"]
        ),
    ],
    targets: [
        .target(
            name: "OrdoEssentials",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport"),
                .unsafeFlags(["-enable-library-evolution", "-emit-module-interface"])
            ]
	),
    ]
)
