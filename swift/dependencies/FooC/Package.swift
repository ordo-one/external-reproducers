// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FooC",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FooCC",
            targets: ["FooCC"]
        ),
    ],
    dependencies:
    [
        .package(path: "../FooA"),
        .package(path: "../FooB"),
    ],
    targets: [
        .target(
            name: "FooCC",
            dependencies: [
                .product(name: "FooAA", package: "FooA"/*, moduleAliases: ["Helpers": "__UNNEEDED_HELPERS"]*/),
                .product(name: "FooBB", package: "FooB"),
            ]
        ),
    ]
)
