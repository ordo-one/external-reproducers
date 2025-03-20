import ArgumentParser
import Foundation
import Synchronization

final class SharedState: Sendable {
    struct State {
        var cancelled = 0
        var continuation: CheckedContinuation<Void, any Error>?
    }

    let state = Mutex<State>(.init())
}

@main
struct Main: AsyncParsableCommand {
    func testFunc(_ iteration: Int) async {
        let task = Task {
            let sharedState = SharedState()
            return try await withTaskCancellationHandler(
                operation: {
                    try await withCheckedThrowingContinuation { continuation in
                        let cancelled = sharedState.state.withLock {
                            if $0.cancelled > 0 {
                                return true
                            } else {
                                $0.continuation = continuation
                                return false
                            }
                        }
                        if cancelled {
                            continuation.resume(throwing: CancellationError())
                        }
                    }
                },
                onCancel: {
                    let continuation = sharedState.state.withLock {
                        $0.cancelled += 1
                        if $0.cancelled > 1 {
                            fatalError("onCancel() called second time on iteration \(iteration)")
                        }
                        return $0.continuation.take()
                    }
                    if let continuation {
                        continuation.resume(throwing: CancellationError())
                    }
                }
            )
        }

        task.cancel()

        let taskResult = await task.result
        switch taskResult {
        case .success:
            fatalError("success not expected")
        case let .failure(error):
            if !(error is CancellationError) {
                fatalError("task should be cancelled")
            }
        }
    }

    mutating func run() async throws {
        let count = 1_000_000
        for idx in 1...count {
            await testFunc(idx)
        }
        print("done")
    }
}
