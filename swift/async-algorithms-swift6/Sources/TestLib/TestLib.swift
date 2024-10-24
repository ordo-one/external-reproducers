import struct AsyncAlgorithms.MultiProducerSingleConsumerChannel

public func foo() async throws {
    let channelAndSource = MultiProducerSingleConsumerChannel<Int, Never>.makeChannel(
        backpressureStrategy: .watermark(low: 10, high: 20)
    )

    var channelSource = consume channelAndSource.source

    Task {
        try await channelSource.send(1)
    }

    Task {
        try await channelSource.send(2)
    }
}
