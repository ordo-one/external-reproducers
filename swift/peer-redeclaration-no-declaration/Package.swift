// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "PeerSample",
    platforms: [
      .iOS("13.0"),
      .macOS("10.15")
    ],
    products: [
      .executable(
        name: "PeerSample",
        targets: ["PeerSample"]
      ),
    ],
    dependencies: [
      .package(
        url: "https://github.com/apple/swift-syntax.git",
        branch: "main"
      ),
    ],
    targets: [
      .macro(name: "PeerSamplePlugin",
        dependencies: [
          .product(name: "SwiftSyntax", package: "swift-syntax"),
          .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
          .product(name: "SwiftOperators", package: "swift-syntax"),
          .product(name: "SwiftParser", package: "swift-syntax"),
          .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
          .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        ]
      ),
      .target(name: "PeerSampleLib",
        dependencies: ["PeerSamplePlugin"]
      ),
      .executableTarget(name: "PeerSample",
        dependencies: [
          "PeerSampleLib"
        ]
      )
    ]
)

