// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "task-cancellation",
    platforms: [
        .macOS(.v15)
    ],
    targets: [
        .executableTarget(name: "task-cancellation")
    ]
)
