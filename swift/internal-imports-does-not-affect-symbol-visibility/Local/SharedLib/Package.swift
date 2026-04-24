// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SharedLib",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "SharedLib",
            targets: ["SharedLib"]
        ),
    ],
    targets: [
        .target(
            name: "SharedLib"
        ),
    ]
)
