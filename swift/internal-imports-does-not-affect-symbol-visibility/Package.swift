// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "InternalImportRepro",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "PluginA",
            type: .dynamic,
            targets: ["PluginA"]
        ),
        .library(
            name: "PluginB",
            type: .dynamic,
            targets: ["PluginB"]
        ),
        .executable(
            name: "Loader",
            targets: ["Loader"]
        ),
    ],
    dependencies: [
        .package(name: "SharedLib", path: "Local/SharedLib"),
    ],
    targets: [
        .target(
            name: "PluginA",
            dependencies: [
                .product(name: "SharedLib", package: "SharedLib"),
            ]
        ),
        .target(
            name: "PluginB",
            dependencies: [
                .product(name: "SharedLib", package: "SharedLib"),
            ]
        ),
        .executableTarget(
            name: "Loader"
        ),
    ]
)
