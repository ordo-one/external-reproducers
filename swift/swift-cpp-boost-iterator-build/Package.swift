// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "package-test-interop",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
//        .library(
//            name: "CppLib",
//            targets: ["CppTarget"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Boost",
//            providers: [.brewItem(["boost"])]
            path: "Sources/Boost",
            exclude: [],
            publicHeadersPath: "./include/",
            cxxSettings: [
                .headerSearchPath("./"),
            ]
        ),
        .target(
            name: "BoostWrapper",
//            providers: [.brewItem(["boost"])]
            path: "Sources/BoostWrapper",
            exclude: [],
            publicHeadersPath: "./include/",
            cxxSettings: [
                .headerSearchPath("./"),
            ]
        ),
        .executableTarget(
            name: "CppTargetTest",
            dependencies: [
                "Boost",
                "BoostWrapper"
            ],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        )
    ],
    cxxLanguageStandard: .gnucxx17
)
