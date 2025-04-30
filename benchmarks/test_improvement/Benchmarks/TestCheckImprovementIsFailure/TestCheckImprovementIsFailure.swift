//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kafka-client open source project
//
// Copyright (c) 2023 Apple Inc. and the swift-kafka-client project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of swift-kafka-client project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import Benchmark

extension Benchmark {
    @discardableResult
    func withMeasurement<T>(_ body: () throws -> T) rethrows -> T {
        self.startMeasurement()
        defer {
            self.stopMeasurement()
        }
        return try body()
    }

    @discardableResult
    func withMeasurement<T>(_ body: () async throws -> T) async rethrows -> T {
        self.startMeasurement()
        defer {
            self.stopMeasurement()
        }
        return try await body()
    }
}

let benchmarks = {
    Benchmark.defaultConfiguration = .init(
        metrics: [.wallClock, .instructions],
        warmupIterations: 0,
        scalingFactor: .one,
        maxDuration: .seconds(5),
        maxIterations: 100 
   )

    Benchmark.setup = {
    }

    Benchmark.teardown = {
    }

    Benchmark("EmptyTest") { benchmark in
        try await benchmark.withMeasurement {
            // try await Task.sleep(for: .seconds(1))
            try await Task.sleep(for: .milliseconds(1))
        }
    }
/*
    Benchmark("EmptyTest2") { benchmark in
        try await benchmark.withMeasurement {
            try await Task.sleep(for: .microseconds(1))
        }
    }
*/
}
