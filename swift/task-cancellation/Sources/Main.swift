import Synchronization

struct State {
    var cancelled = 0
    var continuation: CheckedContinuation<Void, Never>?
}

func testFunc(_ iteration: Int) async {
    let state = Mutex(State())

    let task = Task {
        await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                let cancelled = state.withLock {
                    if $0.cancelled > 0 {
                        return true
                    } else {
                        $0.continuation = continuation
                        return false
                    }
                }
                if cancelled {
                    continuation.resume()
                }
            }
        } onCancel: {
            let continuation = state.withLock {
                $0.cancelled += 1
                return $0.continuation.take()
            }
            continuation?.resume()
        }
    }

    task.cancel()
    _ = await task.value

    let cancelled = state.withLock { $0.cancelled }
    precondition(cancelled == 1, "cancelled more than once, iteration: \(iteration)")
}

for iteration in 0 ..< 1_000_000 {
    await testFunc(iteration)
}

print("done")
