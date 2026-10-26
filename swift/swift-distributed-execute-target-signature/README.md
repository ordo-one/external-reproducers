# `executeDistributedTarget` demangles and resolves the target's signature on every received call

A minimal `DistributedActorSystem` whose decoder hands typed arguments straight back (nothing is serialized), a `distributed actor` with four target shapes (no arguments, two `Int`s, a `String` and an `[Int]`, a generic function called with `Int`), and a [package-benchmark](https://github.com/ordo-one/benchmark) suite that drives each target through `executeDistributedTarget` the way a system does on every received call, beside a hand-written dispatch of the same call. The mangled target names are captured from the runtime itself, through `remoteCall` on a remote proxy.

Eight benchmarks, `executeDistributedTarget <target>` and `handWritten <target>` for each target shape, each measured per call: retired instructions, `malloc` calls and wall clock. A sample is a thousand calls (`scalingFactor: .kilo`, the figures divided back per call), a run takes 500 samples after two warm-up samples, and the tables below give the median sample (p50); the exports in `results/` have p0 to p100. Instructions come from `proc_pid_rusage` (process-wide, read at the start and end of each sample, so the harness's own work between samples is outside the window). `malloc` calls are counted by package-benchmark's malloc interposer ([malloc-interposer](https://github.com/ordo-one/malloc-interposer), a dynamic library that replaces libmalloc's entry points, `malloc`, `calloc`, `realloc`, `posix_memalign`, `aligned_alloc`, the `malloc_zone_*` family and `free`, through dyld interposing for every image in the process, `libswiftCore` and `libswiftDistributed` included, and keeps per-thread counters while a measurement is open); it sees the allocations the Distributed runtime makes inside `executeDistributedTarget`, and its counts are the ones libmalloc's `malloc_logger` hook gave the hand-written harness this suite replaces (4, 8, 8 and 10 per call on the snapshot's library, 2, 2, 2 and 7 on the branch head). The interposed `malloc` executes instructions of its own on every allocation, so instructions and wall clock are taken in a second build of the suite without the interposer (`BENCHMARK_DISABLE_MALLOC_INTERPOSER=1`, a trait of the benchmark package), and the `malloc` counts in the default build: `results/<configuration>-timing.md` and `results/<configuration>-mallocs.md`. The warm-up samples take whatever the runtime initialises lazily on the first calls out of the figures.

```bash
# The malloc counts, the default build (with the interposer):
swift package --disable-sandbox benchmark run --metric mallocCountTotal --format markdown --grouping metric --no-progress
# Instructions and wall clock, a build without it:
BENCHMARK_DISABLE_MALLOC_INTERPOSER=1 swift package --disable-sandbox --build-path .build-plain benchmark run \
    --metric instructions --metric wallClock --format markdown --grouping metric --no-progress
```

That runs against the OS `libswiftDistributed` with the toolchain `swift` resolves to. To run against another library the benchmark executable has to be loaded with `DYLD_LIBRARY_PATH`, which does not survive the plugin (dyld strips the `DYLD_*` variables when it launches a restricted binary such as the toolchain's `swift`; a run through the plugin with the variable set measured the OS library), so the benchmark package's `BenchmarkTool` is run directly, with the arguments the plugin would pass it; it spawns the benchmark executable with its own environment. The exports in `results/` were produced this way for every configuration, the Swift 6.4 one included:

```bash
swift build -c release                                                            # with the interposer
BENCHMARK_DISABLE_MALLOC_INTERPOSER=1 swift build -c release --build-path .build-plain   # without it
swift build -c release --target BenchmarkTool
run() {  # run <metrics...>; DYLD_LIBRARY_PATH as set in the environment; the executable in EXE
  .build/release/BenchmarkTool --command run --baseline-storage-path "$PWD" --format markdown --grouping metric \
      --no-progress --benchmark-executable-paths "$EXE" --targets ExecuteDistributedTarget "$@"
}
EXE=$PWD/.build/release/ExecuteDistributedTarget run --metrics mallocCountTotal > results/64-mallocs.md
EXE=$PWD/.build-plain/release/ExecuteDistributedTarget run --metrics instructions --metrics wallClock > results/64-timing.md
```

What it shows: on the shipped runtime every received call pays for `swift_func_getParameterCount`, `swift_func_getParameterTypeInfo` and `swift_func_getReturnTypeInfo` on the target's mangled name, three demangles and the type resolution behind them, plus eight allocations for a two-argument target (the UTF-8 copy of the name, one demangler slab per introspection call, the parameter type buffer, an `argumentTypes` array nothing reads, the result buffer, and the implicit `utf8CString` conversion of the name). The cost does not fall with repetition: in every committed export the runtime path's cheapest sample (p0) is within 0.3 % of its median instructions, and the p90 within 7.9 % (the most on `String` plus `[Int]` on the branch head, 9,363 against 8,675).

The hand-written dispatch (a dictionary lookup on the identifier, the arguments decoded in declaration order, the local call through the distributed thunk) is an optimised lower bound, not a measure of the signature resolution alone: besides skipping the resolution it decodes the arguments and delivers the result with the types known statically, with no result buffer and no dynamic handler invocation, and it calls the generic target specialised to `Int`. On Swift 6.4 it is 17 to 36 times fewer instructions than the runtime path and allocates nothing. The shipped library against the branch head, below, is the combined effect of the branch; the saving attributable to the signature cache alone is the library built from the commit before the cache against the one built from the branch head, with the same flags.

## Against a rebuilt `libswiftDistributed`

On macOS the Distributed library ships in the OS, so to measure a change to it the suite is built with a development snapshot toolchain and run with that toolchain's own `libswiftCore`, `libswift_Concurrency` and `libswiftDistributed`, replacing the last with a rebuilt one. A full stdlib build is not needed: `build-libswiftDistributed.sh` compiles `stdlib/public/Distributed` (seven Swift files and one C++ file; two from the cache commit on, which adds the threading error handler the shared library needs on Linux) from a `swiftlang/swift` checkout with the snapshot's own compilers and links it against the snapshot's stdlib. Its Swift flags are the ones the snapshot recorded in its `Distributed.swiftinterface` plus those the Distributed `CMakeLists.txt` and the stdlib's cmake modules add; its C++ flags those of a release runtime build: `-O2 -DNDEBUG`, no exceptions or RTTI, hidden visibility, and the defines `AddSwiftStdlib.cmake` emits for a macOS stdlib build with the defaults of `StdlibOptions.cmake` (of its `SWIFT_STDLIB_*` and `SWIFT_CONCURRENCY_*` defines, the headers the C++ file includes test `SWIFT_STDLIB_HAS_DARWIN_LIBMALLOC`, which has `Runtime/Concurrent.h` size the hash map storage the cache uses with `malloc_good_size`, and `SWIFT_CONCURRENCY_USES_DISPATCH` in `ABI/Task.h`; the others are passed for fidelity). The Swift sources are compiled with the flags the swiftinterface records; of the `-D` conditions the stdlib build adds on the Swift side, Distributed's sources test one, which is off on macOS. The availability macros are derived from `utils/availability-macros.def` as the stdlib build derives them. Every flag is in the script. It builds for arm64 and requires native arm64 macOS, which it checks with `uname -m`.

One line of source is added for the measurement when a revision lacks it. `dispatchToDistributedAccessor` ends in the call into the accessor's async entry, which resumes the caller's context itself, so that call has to be a tail call, and it only is one once the function is inlined into the two `swiftasync` entry points; the branch's last commit marks it `SWIFT_ALWAYS_INLINE`, earlier revisions relied on the optimizer's heuristic. The script compiles the C++ file from a copy to which it adds the attribute when the revision does not carry it (and says so), so that every rebuilt library, the control included, is compiled the same way, and it fails if an out-of-line copy of the function remains in the object or either entry point does not end in the indirect branch into the accessor.

```bash
# TC: the snapshot toolchain's root, the directory holding usr/bin/swiftc and usr/lib/swift/macosx,
#     either an installed /Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-<date>-a.xctoolchain
#     or the Payload directory of `pkgutil --expand-full <snapshot>.pkg <dir>`.
# SRC: a checkout of swiftlang/swift at the revision to build.
"$TC/usr/bin/swift" build -c release --build-path .build-main
BENCHMARK_DISABLE_MALLOC_INTERPOSER=1 "$TC/usr/bin/swift" build -c release --build-path .build-main-plain
"$TC/usr/bin/swift" build -c release --build-path .build-main --target BenchmarkTool
run() {
  .build-main/release/BenchmarkTool --command run --baseline-storage-path "$PWD" --format markdown --grouping metric \
      --no-progress --benchmark-executable-paths "$EXE" --targets ExecuteDistributedTarget "$@"
}

# The snapshot's own library, for the baseline:
export DYLD_LIBRARY_PATH="$TC/usr/lib/swift/macosx"
EXE=$PWD/.build-main/release/ExecuteDistributedTarget run --metrics mallocCountTotal > results/snapshot-mallocs.md
EXE=$PWD/.build-main-plain/release/ExecuteDistributedTarget run --metrics instructions --metrics wallClock > results/snapshot-timing.md

# A rebuilt one:
TC="$TC" SRC="$SRC" ./build-libswiftDistributed.sh rebuilt
export DYLD_LIBRARY_PATH="$PWD/rebuilt/lib:$TC/usr/lib/swift/macosx"
EXE=$PWD/.build-main/release/ExecuteDistributedTarget run --metrics mallocCountTotal > results/rebuilt-mallocs.md
EXE=$PWD/.build-main-plain/release/ExecuteDistributedTarget run --metrics instructions --metrics wallClock > results/rebuilt-timing.md
```

The control, the check that the recipe is right: a library rebuilt from the snapshot's own revision measures the same as the snapshot's own library. In the committed exports (`results/control-*.md` against `results/snapshot-*.md`) the two agree to within 360 instructions per call on three targets and within 492 on the `String` plus `[Int]` target, and the `malloc` counts are identical.

## Numbers

Apple M4 Max (16 cores, 128 GB), macOS 27.0 (26A428); the full environment, the package versions, and the revision, compilers and checksum behind each configuration are recorded in `results/MANIFEST.md`. Each table is the median sample (p50) of the committed exports `results/<configuration>-timing.md` (instructions and wall clock, the build without the interposer) and `results/<configuration>-mallocs.md` (the default build), 500 samples of a thousand calls each. The five configurations were run one after the other within each round, from executables built fresh for the work: the `malloc` round on 2026-10-26 at 09:03 at a one-minute load average of 7.13 to 7.49 (the counts do not depend on the load), the timing round on 2026-10-26 at 10:17 at a one-minute load average of 2.36 to 2.43, on a quiet machine with nothing else running (the hand-written harness this suite replaces measured the same five configurations on a quiet machine earlier the same day, `results/*.txt` at commit `a3ec79f`; its runtime-path instruction medians are within 1 % of these on 15 of the 20 rows and within 5 % on all, and its allocation counts are identical).

Swift 6.4 as shipped, against the OS library (`results/64-*.md`):

```text
                 runtime path (`executeDistributedTarget`)         hand-written dispatch (lower bound)
noArgs            22,217 instructions    4 mallocs    911 ns    1,287 instructions   0 mallocs    63 ns
twoInts           44,237                 8          1,711 ns    1,563                0            74 ns
stringAndArray    54,559                 8          2,120 ns    2,632                0           132 ns
generic           52,036                10          2,040 ns    1,464                0            70 ns
```

Main snapshot 2026-10-17, its own `libswiftDistributed` (already rejecting unknown targets before demangling, swiftlang/swift#92264, and passing the name's byte length, swiftlang/swift#92090) (`results/snapshot-*.md`):

```text
                 runtime path (`executeDistributedTarget`)         hand-written dispatch (lower bound)
noArgs            21,299 instructions    4 mallocs    785 ns    1,326 instructions   0 mallocs    59 ns
twoInts           35,946                 8          1,362 ns    1,509                0            68 ns
stringAndArray    45,449                 8          1,714 ns    2,398                0           108 ns
generic           44,564                10          1,709 ns    1,415                0            63 ns
```

The same snapshot with `libswiftDistributed` rebuilt from its own revision `f62414fd`, the control (`results/control-*.md`):

```text
                 runtime path (`executeDistributedTarget`)         hand-written dispatch (lower bound)
noArgs            21,299 instructions    4 mallocs    791 ns    1,256 instructions   0 mallocs    59 ns
twoInts           35,586                 8          1,337 ns    1,509                0            70 ns
stringAndArray    45,941                 8          1,736 ns    2,609                0           112 ns
generic           44,433                10          1,706 ns    1,415                0            65 ns
```

The same snapshot with `libswiftDistributed` rebuilt from `fc4eb53c` alone (fewer allocations; `results/alloc-*.md`):

```text
                 runtime path (`executeDistributedTarget`)         hand-written dispatch (lower bound)
noArgs            20,365 instructions    3 mallocs    740 ns    1,256 instructions   0 mallocs    59 ns
twoInts           34,669                 6          1,306 ns    1,509                0            70 ns
stringAndArray    44,073                 6          1,676 ns    2,660                0           117 ns
generic           42,828                 8          1,653 ns    1,415                0            64 ns
```

The same snapshot with `libswiftDistributed` rebuilt from the branch head `12d8a8cd` (fewer allocations, the signature cache and the explicit inlining; `results/head-*.md`):

```text
                 runtime path (`executeDistributedTarget`)         hand-written dispatch (lower bound)
noArgs             3,658 instructions    2 mallocs    150 ns    1,256 instructions   0 mallocs    59 ns
twoInts            7,946                 2            295 ns    1,579                0            73 ns
stringAndArray     8,675                 2            325 ns    2,398                0           109 ns
generic           33,096                 7          1,284 ns    1,415                0            67 ns
```

Runtime path against runtime path, the branch head against the snapshot's own library is the combined effect of the branch: the two-`Int` call goes from 35,946 to 7,946 instructions (4.5 times fewer) and from 8 to 2 `malloc` calls, the no-argument call from 21,299 to 3,658 (5.8 times fewer) and from 4 to 2, `String` plus `[Int]` from 45,449 to 8,675 (5.2 times fewer) and from 8 to 2; the generic target keeps its per-call type resolution and goes from 44,564 to 33,096 (1.3 times fewer) and from 10 to 7. The signature cache alone is the branch head against the allocations commit, built with the same flags: the two-`Int` call from 34,669 to 7,946 (4.4 times fewer) and from 6 to 2 `malloc` calls, the no-argument call from 20,365 to 3,658 (5.6 times fewer) and from 3 to 2, `String` plus `[Int]` from 44,073 to 8,675 (5.1 times fewer) and from 6 to 2, the generic target from 42,828 to 33,096 (1.3 times fewer) and from 8 to 7. The allocations commit alone saves 934 to 1,736 instructions per call and one `malloc` call for the no-argument target, two for the others. The two `malloc` calls left on a non-generic target are the UTF-8 copy of the name and the result buffer.

## Revisions

- Toolchains: Apple Swift 6.4 (Xcode 27.1, `swiftlang-6.4.0.34.1`), and the main development snapshot `swift-DEVELOPMENT-SNAPSHOT-2026-10-17-a` (Swift 6.5-dev, built from `swiftlang/swift` `f62414fd1d17227`, the control's revision). The suite depends on `ordo-one/benchmark` 1.38.0, which brings `ordo-one/malloc-interposer` 1.6.0.
- `swiftlang/swift` main at `c9ed278c` (2026-10-25), the base of the branch `distributed/cache-target-signature`, published at https://github.com/hassila/swift/tree/distributed/cache-target-signature, four commits:
  - `fc4eb53c`: drops the unused `argumentTypes` array and the `utf8CString` conversion of the name (one allocation per call for the no-argument target, two for the others).
  - `ba66af26`: resolves a target's signature once per accessor record (a `ConcurrentReadableHashMap` keyed by the record, holding the parameter count, the parameter and return type metadata and the generic environment, filled on first use with the same introspection entry points; a generic target still resolves its types per call). The cache is the library's first use of the runtime's threading primitives, so the commit also gives the shared library the runtime's threading objects and adds `ThreadingError.cpp` for their error handler, as `_Concurrency` does, in the stdlib build and in the standalone `Runtimes` build alike; on Darwin neither is reached.
  - `631ffdd3`: the tests.
  - `12d8a8cd`: marks the accessor dispatcher `SWIFT_ALWAYS_INLINE`. Every rebuilt library carries the attribute, the control included (see the build script), so it is not a variable in any table.

The measured libraries were built for this run from `git archive`s of `12d8a8cd` (sha256 `58fba5b8531c43fca082fa322de581a55092de93012691c7a5399923768ae3b9`), `fc4eb53c` (`f63655c605dbb984199b4d34dd0c0a49d88b0274b1bee533e31f8a30ba424bc7`) and `f62414fd` (`86b90e58e548203bb84ab416d2aa92e87277a994f943cdab57a2aa7bda00727b`). The library built from `12d8a8cd` is byte for byte the one the hand-written harness this suite replaces measured, which was built from `0a5029b3`, the branch head as it stood then (same sha256), and the one built from `fc4eb53c` is byte for byte the one it measured as the allocations commit, built from `c44b49ed`; the branch has since been rebased onto main `c9ed278c` without a change to any patch, and nothing between those revisions touches what the script compiles. `results/MANIFEST.md` has the machine, the toolchains, the package versions and the revision, compilers and checksum behind every configuration.

To build the measured libraries, in a clone of `swiftlang/swift`:

```bash
git fetch https://github.com/hassila/swift distributed/cache-target-signature   # the repository the branch is published in
git checkout 12d8a8cd                                              # the branch head
git checkout fc4eb53c                                              # the allocations commit alone
git fetch origin f62414fd1d17227037adf18df53a1dd95f72f1a2 && git checkout FETCH_HEAD   # the control (full hash needed)
```
