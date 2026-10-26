# Measurement manifest

Where the committed exports in this directory were taken, and what built the code behind each configuration.

## Machine

- Apple M4 Max, 16 cores (12 performance, 4 efficiency), 128 GB, arm64.
- macOS 27.0, build 26A428.
- The `malloc` exports were taken on 2026-10-26 at 09:03 at a one-minute load average of 7.13 to 7.49 and the timing exports on 2026-10-26 at 10:17 at a one-minute load average of 2.36 to 2.43, the five configurations one after the other within each round, from benchmark executables built fresh for the work. The `malloc` counts do not depend on the load; instructions are process-wide and include whatever else the process's threads do inside a sample; the wall clock depends on the machine's state and is the figure to read with the load in mind; the machine was quiet during the timing round, with nothing else running.

## Toolchains and packages

- Xcode 27.1 (build 27A9275): Apple Swift version 6.4 (`swiftlang-6.4.0.34.1 clang-2100.3.34.1`), swift-driver 1.168.6. Builds the `64` executables, which run against the `libswiftDistributed` of macOS 27.0 (26A428).
- `swift-DEVELOPMENT-SNAPSHOT-2026-10-17-a` (bundle `org.swift.65202610171a`): Apple Swift version 6.5-dev (LLVM `9b3700c0bd7ce7a`, Swift `f62414fd1d17227`), Apple clang version 23.0.0 (`swiftlang/llvm-project` `9b3700c0bd7ce7a316be346fec8f2fd78ea0ab8a`). Builds the `.build-main*` executables and every rebuilt library: the snapshot's `swiftc` compiles the Swift files and links the library, its `clang++` compiles the C++ files.
- `ordo-one/benchmark` 1.38.0 (the benchmark runner and its `BenchmarkTool`), with `ordo-one/malloc-interposer` 1.6.0 counting the `malloc` calls; the other packages it resolves are `hdrhistogram-swift` 0.2.0, `swift-argument-parser` 1.8.2, `swift-atomics` 1.3.1, `swift-numerics` 1.1.1, `swift-system` 1.8.1, `texttable` 0.0.2.

## Builds and exports

Each toolchain builds the suite twice: the default build, with the malloc interposer (`.build`, `.build-main`), whose `BenchmarkTool` runs every configuration and whose benchmark executable produces `<configuration>-mallocs.md` (`--metrics mallocCountTotal`); and a build without it (`BENCHMARK_DISABLE_MALLOC_INTERPOSER=1`; `.build-plain`, `.build-main-plain`), whose benchmark executable produces `<configuration>-timing.md` (`--metrics instructions --metrics wallClock`). `BenchmarkTool` is run directly, not through the `swift package benchmark` plugin, so that `DYLD_LIBRARY_PATH` reaches the benchmark executable; the `64` configuration is run the same way without the variable. An export is `BenchmarkTool`'s markdown output with `--grouping metric`: one table per metric, a row per benchmark with p0, p25, p50, p75, p90, p99, p100 and the sample count, per call (the benchmarks scale by a thousand calls per sample), with the units pinned to counts and nanoseconds by the benchmark configuration so that the values are exact. Every row has 500 samples.

## Configurations

Every rebuilt library was built once for this run with `build-libswiftDistributed.sh` from a `git archive` of the revision named, and its sha256 is given.

| Configuration | Executables | `libswiftDistributed` | `swiftlang/swift` revision compiled | sha256 |
|---|---|---|---|---|
| `64` | Xcode 27.1, Swift 6.4 | the OS library, macOS 27.0 (26A428) | none (shipped binary) | |
| `snapshot` | snapshot 2026-10-17 | the snapshot's own | none (shipped binary, the snapshot's `f62414fd1d17227`) | |
| `control` | snapshot 2026-10-17 | rebuilt with the snapshot's compilers | `f62414fd1d17227037adf18df53a1dd95f72f1a2`, the snapshot's own revision | `86b90e58e548203bb84ab416d2aa92e87277a994f943cdab57a2aa7bda00727b` |
| `alloc` | snapshot 2026-10-17 | rebuilt with the snapshot's compilers | `fc4eb53c`, the allocations commit alone on main `c9ed278c` | `f63655c605dbb984199b4d34dd0c0a49d88b0274b1bee533e31f8a30ba424bc7` |
| `head` | snapshot 2026-10-17 | rebuilt with the snapshot's compilers | `813f78b3`, the branch head | `58fba5b8531c43fca082fa322de581a55092de93012691c7a5399923768ae3b9` |

The `control` and `alloc` libraries were compiled with `SWIFT_ALWAYS_INLINE` added to `dispatchToDistributedAccessor` by the script, since those revisions do not carry it; the `head` library carries it in its source.

## The head revision

The branch `distributed/cache-target-signature` published for review has the head `813f78b3` (commits `fc4eb53c`, `d66b7bd0`, `8d1c4f1b`, `813f78b3` on main `c9ed278c`), and the `head` library was built from it. The hand-written harness this suite replaces measured a library built from `0a5029b3`, the head as it stood before the branch was rebased onto `c9ed278c` without a change to any patch; the library the script builds from `813f78b3` is byte for byte that one (sha256 `58fba5b8531c43fca082fa322de581a55092de93012691c7a5399923768ae3b9`), and the one it builds from `fc4eb53c` is byte for byte the one built from `c44b49ed`, the allocations commit before the rebase (sha256 `f63655c605dbb984199b4d34dd0c0a49d88b0274b1bee533e31f8a30ba424bc7`). None of the commits the rebase took touches what the script compiles. After this run the cache commit's message was corrected (`ba66af26` is now `d66b7bd0`), so it and the two commits after it took new hashes (`631ffdd3` is `8d1c4f1b`, `12d8a8cd` is `813f78b3`) with the same trees; the libraries were built from `git archive`s of `12d8a8cd`, whose tree `813f78b3` has.
