import AsyncAlgorithms

public func foo() -> MultiProducerSingleConsumerChannel<Int, Never> {
    let channelAndSource = MultiProducerSingleConsumerChannel<Int, Never>.makeChannel(
        backpressureStrategy: .watermark(low: 10, high: 20)
    )
    return channelAndSource.channel
}
