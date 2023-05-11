// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Api",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Api",
            targets: ["Api"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-bundle", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(
            name: "Api",
            dependencies: [
                .product(name: "Bundle", package: "package-bundle"),
            ]
        ),
    ]
)
