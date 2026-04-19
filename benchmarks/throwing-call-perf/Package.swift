// swift-tools-version: 6.2
import PackageDescription

let package: Package = .init(
    name: "ThrowingCallPerf",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
    ],
    products: [
        .library(
            name: "ThrowingCallPerf",
            type: .dynamic,
            targets: ["ThrowingCallPerf"]
        ),
    ],
    targets: [
        .target(
            name: "ThrowingCallPerf",
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution", "-emit-module-interface"]),
            ]
        ),
    ]
)
