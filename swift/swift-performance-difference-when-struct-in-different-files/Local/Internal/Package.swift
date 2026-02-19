// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Internal",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "Internal", type: .dynamic, targets: ["Internal"]),
    ],
    dependencies: [
        .package(path: "../Essentials"),
    ],
    targets: [
        .target(
            name: "Internal",
            dependencies: [
                .product(name: "Essentials", package: "Essentials"),
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution", "-emit-module-interface"])
            ]
        ),
    ]
)
