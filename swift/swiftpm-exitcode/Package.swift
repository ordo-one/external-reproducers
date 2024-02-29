// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swiftpm-exitcode",
    products: [
    ],
    targets: [
        .plugin(
            name: "CrashingPlugin",
            capability: .command(
                intent: .custom(
                    verb: "crash",
                    description: "Crash with an exit code > 1."
                )
            ),
            path: "Plugins/CrashingPlugin"
        ),
    ]
)
