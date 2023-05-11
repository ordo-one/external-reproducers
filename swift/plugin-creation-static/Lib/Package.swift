// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Lib",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Lib",
            type: .dynamic,
            targets: ["Lib"]
        )
    ],
    dependencies: [
        .package(name: "Api", path: "../Api/")
    ],
    targets: [
        .target(
            name: "Lib",
            dependencies: [
                "Api",
            ]
        ),
    ]
)
