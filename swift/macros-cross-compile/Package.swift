// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "macros-cross-compile",
    platforms: [
        .macOS(.v14)
    ],
    products: [],
    dependencies: [
        .package(url: "https://github.com/ordo-one/swift-foundation", .upToNextMajor(from: "0.0.13")),
        .package(url: "https://github.com/apple/swift-syntax.git", .upToNextMajor(from: "509.0.0"))
    ],
    targets: [
        .executableTarget(
            name: "MacrosCrossCompile",
            dependencies: [
                .product(name: "FoundationEssentials", package: "swift-foundation"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        )
    ]
)
