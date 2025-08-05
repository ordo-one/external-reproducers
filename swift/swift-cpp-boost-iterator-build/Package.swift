// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "package-test-interop",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .binaryTarget(
            name: "Boost.FileSystem",
            url: "https://api.github.com/repos/ordo-one/external-reproducers/releases/assets/279506048-boost_filesystem.artifactbundle.zip",
            checksum: "140803e7d8bf43ec6e1ee69ebee18a243049cd469ea5692d57f2d625dba9e855"
        ),
        .target(
            name: "Boost",
            dependencies: ["Boost.FileSystem"],
            path: "Sources/Boost",
            exclude: [],
            publicHeadersPath: "./",
            cxxSettings: [
                .headerSearchPath("./"),
            ],
            linkerSettings: [
                .linkedLibrary("boost_filesystem")
            ]
        ),
        .executableTarget(
            name: "CppTargetTest",
            dependencies: [
                "Boost",
            ],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        )
    ],
    cxxLanguageStandard: .gnucxx17
)
