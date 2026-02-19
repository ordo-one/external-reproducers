// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Essentials",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "Essentials", type: .dynamic, targets: ["Essentials"]),
    ],
    targets: [
        .target(
            name: "Essentials",
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution", "-emit-module-interface"])
            ]
        ),
    ]
)
