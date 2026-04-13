// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Reproducer",
    platforms: [
        .macOS(.v26),
    ],
    products: [
        .library(name: "RawBytes", targets: ["RawBytes"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RawBuffer"
        ),
        .target(
            name: "RawBytes",
            dependencies: ["RawBuffer"]
        ),
    ]
)
