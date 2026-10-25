// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "swift-distributed-execute-target-signature",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(name: "ExecuteDistributedTarget"),
    ]
)
