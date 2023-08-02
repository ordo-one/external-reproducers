// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FooB",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FooBB",
            targets: ["FooBB"]
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
            name: "FooBB",
            dependencies: [
                "Helpers"
            ]
        ),
    ]
)
