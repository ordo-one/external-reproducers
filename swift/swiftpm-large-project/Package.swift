// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "swiftpm-large-project",
    platforms: [
        .macOS(.v15),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.5"),
        .package(url: "https://github.com/apple/swift-nio", from: "2.86.2"),
        .package(url: "https://github.com/apple/swift-system", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-distributed-tracing", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-metrics", from: "2.3.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-algorithms", "1.2.0" ..< "1.2.1"),
        .package(url: "https://github.com/apple/swift-service-discovery", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-crypto", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-profile-recorder", from: "0.3.9"),

        .package(url: "https://github.com/swift-server/async-http-client", from: "1.25.0"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle", from: "2.6.3"),
        .package(url: "https://github.com/swift-server/swift-prometheus", from: "2.0.0"),
        .package(url: "https://github.com/swift-server/swift-kafka-client", from: "1.0.0-alpha.9"),

        .package(url: "https://github.com/grpc/grpc-swift-2", from: "2.1.0"),
        .package(url: "https://github.com/grpc/grpc-swift-nio-transport", from: "2.2.0"),
        .package(url: "https://github.com/grpc/grpc-swift-protobuf", from: "2.1.0"),

        .package(url: "https://github.com/swift-otel/swift-otel", from: "1.0.0"),

        .package(url: "https://github.com/swiftlang/swift-subprocess", .upToNextMajor(from: "0.3.0"), traits: []),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "602.0.0"),
        .package(url: "https://github.com/swiftlang/swift-lmdb", revision: "swift-6.1.1-RELEASE"),

        .package(url: "https://github.com/soto-project/soto-s3-file-transfer", from: "2.1.0"),
        .package(url: "https://github.com/soto-project/soto", from: "7.0.0"),

        .package(url: "https://github.com/google/flatbuffers", from: "25.2.10"),

        .package(url: "https://github.com/groue/Semaphore", from: "0.0.8"),
        .package(url: "https://github.com/sushichop/Puppy", from: "0.8.0"),
        .package(url: "https://github.com/HdrHistogram/hdrhistogram-swift", from: "0.1.2"),
    ],
    targets: [
        .executableTarget(
            name: "LargeProject",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "SystemPackage", package: "swift-system"),
                .product(name: "Tracing", package: "swift-distributed-tracing"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Metrics", package: "swift-metrics"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "ServiceDiscovery", package: "swift-service-discovery"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "Prometheus", package: "swift-prometheus"),
                .product(name: "GRPCCore", package: "grpc-swift-2"),
                .product(name: "GRPCNIOTransportHTTP2", package: "grpc-swift-nio-transport"),
                .product(name: "GRPCProtobuf", package: "grpc-swift-protobuf"),
                .product(name: "OTel", package: "swift-otel"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "Semaphore", package: "Semaphore"),
                .product(name: "Puppy", package: "Puppy"),
                .product(name: "Histogram", package: "hdrhistogram-swift"),
                .product(name: "SotoS3FileTransfer", package: "soto-s3-file-transfer"),
                .product(name: "SotoS3", package: "soto"),
                .product(name: "FlatBuffers", package: "flatbuffers"),
                .product(name: "Kafka", package: "swift-kafka-client"),
                .product(name: "CLMDB", package: "swift-lmdb"),
            ],
            path: "Sources"
        ),
    ]
)
