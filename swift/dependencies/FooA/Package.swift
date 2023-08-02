// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FooA",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FooAA",
            targets: ["FooAA"]
        ),
    ],
    dependencies:
    [
    ],
    targets: [
        .target(
            name: "Helpers"
        ),
        .target(
            name: "FooAA",
            dependencies: [
                "Helpers"
            ]
        ),
    ]
)
