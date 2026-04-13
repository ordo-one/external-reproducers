// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Reproducer",
    platforms: [
        .macOS(.v26),
    ],
    products: [
        .library(name: "Reproducer", targets: ["Reproducer"]),
        .library(name: "RawBytes", targets: ["RawBytes"]),
        .library(name: "RawBuffer", targets: ["RawBuffer"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/ordo-one/flatbuffers",
            exact: "25.2.10-ordo.5"
        ),
    ],
    targets: [
        .target(
            name: "Reproducer",
            dependencies: [
                .product(name: "FlatBuffers", package: "flatbuffers"),
            ]
        ),
        .target(
            name: "RawBuffer"
        ),
        .target(
            name: "RawBytes",
            dependencies: ["RawBuffer"]
        ),
    ]
)
