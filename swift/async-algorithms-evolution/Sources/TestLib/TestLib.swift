internal import struct AsyncAlgorithms.MultiProducerSingleConsumerChannel

public func foo() {
    _ = MultiProducerSingleConsumerChannel<Int, Never>.makeChannel(
        backpressureStrategy: .watermark(low: 10, high: 20)
    )
}

