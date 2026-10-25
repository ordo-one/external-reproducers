// Per received distributed call, for each target shape, the runtime’s `executeDistributedTarget` beside a
// hand-written dispatch of the same call, in one of two modes chosen on the command line:
//
//   timing       retired instructions (`proc_pid_rusage`) and wall clock per call
//   allocations  allocation events per call, counted by libmalloc’s `malloc_logger` hook (the hook the
//                MallocStackLogging facility uses), installed once before the first measurement
//
// Both are process-wide totals divided by the number of calls. The modes are separate processes so that
// the hook’s cost is never part of a timing figure. Figures are the median over the batches (the mean of
// the two middle samples, the count being even), with the first and last batch shown so a cost that fell
// with repetition would be visible; the first batch of a process includes any lazy initialisation.

import Darwin
import Distributed
import Foundation
import Synchronization

let batches = 20
let callsPerBatch = 10_000

enum Mode: String {
    case timing, allocations
}

guard CommandLine.arguments.count == 2, let mode = Mode(rawValue: CommandLine.arguments[1]) else {
    FileHandle.standardError.write(Data("usage: \(CommandLine.arguments[0]) timing|allocations\n".utf8))
    exit(2)
}

// Counted from every allocating thread, so an atomic; relaxed is enough for a count. (Top-level lets in
// main.swift are main-actor isolated; a `Sendable` constant is readable from the measuring task anyway.)
let allocationCount = Atomic<Int>(0)

// libmalloc calls `malloc_logger` for every allocation event while it is set; type bit 2 is an allocation.
typealias MallocLogger = @convention(c) (UInt32, UInt, UInt, UInt, UInt, UInt32) -> Void
nonisolated(unsafe) let allocationHook: MallocLogger = { type, _, _, _, _, _ in
    if type & 2 != 0 { allocationCount.wrappingAdd(1, ordering: .relaxed) }
}
nonisolated(unsafe) let mallocLoggerSlot = dlsym(UnsafeMutableRawPointer(bitPattern: -2), "malloc_logger")!
    .assumingMemoryBound(to: MallocLogger?.self)

/// One batch of `callsPerBatch` calls: instructions and nanoseconds per call in timing mode, allocation
/// events per call in allocations mode (the other fields stay zero).
struct Batch {
    var instructions: Double = 0
    var nanoseconds: Double = 0
    var allocations: Double = 0
}

func median(_ values: [Double]) -> Double {
    let sorted = values.sorted()
    let middle = sorted.count / 2
    return sorted.count % 2 == 0 ? (sorted[middle - 1] + sorted[middle]) / 2 : sorted[middle]
}

func instructions() -> UInt64 {
    var info = rusage_info_v4()
    let result = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: rusage_info_t?.self, capacity: 1) {
            proc_pid_rusage(getpid(), RUSAGE_INFO_V4, $0)
        }
    }
    precondition(result == 0, "proc_pid_rusage failed")
    return info.ri_instructions
}

func loadAverage() -> String {
    var loads = [Double](repeating: 0, count: 3)
    _ = getloadavg(&loads, 3)
    return String(format: "%.2f %.2f %.2f", loads[0], loads[1], loads[2])
}

func measureTiming(_ body: () async throws -> Void) async rethrows -> Batch {
    let clock = ContinuousClock()
    let startInstructions = instructions()
    let start = clock.now
    for _ in 0..<callsPerBatch {
        try await body()
    }
    let elapsed = clock.now - start
    let retired = instructions() - startInstructions
    let nanoseconds = Double(elapsed.components.seconds) * 1e9 + Double(elapsed.components.attoseconds) / 1e9
    return Batch(instructions: Double(retired) / Double(callsPerBatch),
                 nanoseconds: nanoseconds / Double(callsPerBatch))
}

func measureAllocations(_ body: () async throws -> Void) async rethrows -> Batch {
    let start = allocationCount.load(ordering: .relaxed)
    for _ in 0..<callsPerBatch {
        try await body()
    }
    let events = allocationCount.load(ordering: .relaxed) - start
    return Batch(allocations: Double(events) / Double(callsPerBatch))
}

/// One batch of `callsPerBatch` calls, measured for what the mode asks.
func measure(_ body: () async throws -> Void) async rethrows -> Batch {
    switch mode {
    case .timing: try await measureTiming(body)
    case .allocations: try await measureAllocations(body)
    }
}

func report(_ label: String, _ samples: [Batch]) {
    let first = samples.first!, last = samples.last!
    switch mode {
    case .timing:
        print(String(format: "  %-8@ median %7.0f instructions %6.0f ns   batch 1: %7.0f instructions %6.0f ns   batch %d: %7.0f instructions %6.0f ns",
                     label as NSString,
                     median(samples.map(\.instructions)), median(samples.map(\.nanoseconds)),
                     first.instructions, first.nanoseconds,
                     samples.count, last.instructions, last.nanoseconds))
    case .allocations:
        print(String(format: "  %-8@ median %6.2f allocations   batch 1: %6.2f allocations   batch %d: %6.2f allocations",
                     label as NSString,
                     median(samples.map(\.allocations)),
                     first.allocations,
                     samples.count, last.allocations))
    }
}

/// Off the main actor, so a call onto the worker does not hop between threads on every iteration.
func run() async throws {
    let system = TinyActorSystem()
    let worker = Worker(actorSystem: system)
    let handler = TinyResultHandler()
    let names = try await TargetNames.capture()
    let table = DirectPath.Table(names)

    print("Per received call, \(mode.rawValue) mode: \(batches) batches of \(callsPerBatch) calls each per target and path (the two paths alternate batch by batch); load average \(loadAverage())")
    for target in Target.allCases {
        let identifier = names[target]
        print("\(target.rawValue)  \(identifier)")
        let remoteTarget = RemoteCallTarget(identifier)
        var runtime: [Batch] = []
        var direct: [Batch] = []
        for _ in 0..<batches {
            runtime.append(try await measure {
                var decoder = TinyInvocationDecoder()
                try await RuntimePath.execute(system, on: worker, target: remoteTarget,
                                              decoder: &decoder, handler: handler)
            })
            direct.append(try await measure {
                var decoder = TinyInvocationDecoder()
                try await DirectPath.execute(table, on: worker, identifier: identifier,
                                             decoder: &decoder, handler: handler)
            })
        }
        report("runtime", runtime)
        report("direct", direct)
    }
    print("Load average at the end \(loadAverage())")
}

if mode == .allocations {
    // Installed once, for the life of the process; never installed in timing mode.
    mallocLoggerSlot.pointee = allocationHook
}
try await Task.detached { try await run() }.value
