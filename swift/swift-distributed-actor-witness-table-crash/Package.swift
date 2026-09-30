// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "swift-distributed-actor-witness-table-crash",
    platforms: [.macOS(.v15)],
    targets: [
        .target(name: "Protocols"),
        .target(name: "Implementation", dependencies: ["Protocols"]),
        .target(name: "Client", dependencies: ["Implementation", "Protocols"]),
    ]
)
