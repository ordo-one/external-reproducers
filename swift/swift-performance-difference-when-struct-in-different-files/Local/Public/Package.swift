// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Public",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "Public", type: .dynamic, targets: ["Public"]),
    ],
    dependencies: [
        .package(path: "../Essentials"),
        .package(path: "../Internal"),
    ],
    targets: [
        .target(
            name: "Public",
            dependencies: [
                .product(name: "Essentials", package: "Essentials"),
                .product(name: "Internal", package: "Internal"),
            ],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution", "-emit-module-interface"])
            ]
        ),
    ]
)
