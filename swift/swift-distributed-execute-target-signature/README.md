# `executeDistributedTarget` demangles and resolves the target's signature on every received call

A minimal `DistributedActorSystem` whose decoder hands typed arguments straight back (nothing is serialized), a `distributed actor` with four target shapes (no arguments, two `Int`s, a `String` and an `[Int]`, a generic function called with `Int`), and an executable that drives each target through `executeDistributedTarget` the way a system does on every received call, beside a hand-written dispatch of the same call. The mangled target names are captured from the runtime itself, through `remoteCall` on a remote proxy.

The executable runs in one of two modes, chosen on the command line and meant as separate processes. `timing` prints, per call and per path, retired instructions (`proc_pid_rusage`) and wall clock. `allocations` prints allocation events per call, counted by libmalloc's `malloc_logger` hook (an atomic counter), which is installed once before the first measurement and never in timing mode, so its cost is part of no timing figure. Both are process-wide totals divided by the number of calls, over 20 batches of 10,000 calls per target and path, the runtime path and the hand-written one alternating batch by batch; each figure is the median over the batches (the mean of the two middle ones), printed beside the first and last batch and the load average. The first batch of a process includes whatever the runtime initialises lazily on the first calls.

```bash
swift build -c release
.build/release/ExecuteDistributedTarget timing
.build/release/ExecuteDistributedTarget allocations
```

What it shows: on the shipped runtime every received call pays for `swift_func_getParameterCount`, `swift_func_getParameterTypeInfo` and `swift_func_getReturnTypeInfo` on the target's mangled name, three demangles and the type resolution behind them, plus eight allocations for a two-argument target (the UTF-8 copy of the name, one demangler slab per introspection call, the parameter type buffer, an `argumentTypes` array nothing reads, the result buffer, and the implicit `utf8CString` conversion of the name). The cost does not fall with repetition: in the committed outputs of the shipped runtime and of the snapshot's own library the twentieth batch reads within 0.1 % of the median, and the first reads above it (on the snapshot's own library 4 % more instructions for the no-argument target and under 2 % for the others, `results/snapshot-timing.txt`), which is presumably one-time work, metadata instantiated on the first calls, amortised over that batch's 10,000 calls.

The hand-written dispatch (a dictionary lookup on the identifier, the arguments decoded in declaration order, the local call through the distributed thunk) is an optimised lower bound, not a measure of the signature resolution alone: besides skipping the resolution it decodes the arguments and delivers the result with the types known statically, with no result buffer and no dynamic handler invocation, and it calls the generic target specialised to `Int`. On Swift 6.4 it is 16 to 36 times fewer instructions than the runtime path and allocates nothing. The shipped library against the branch head, below, is the combined effect of the branch; the saving attributable to the signature cache alone is the library built from the commit before the cache against the one built from the branch head, with the same flags.

## Against a rebuilt `libswiftDistributed`

On macOS the Distributed library ships in the OS, so to measure a change to it the executable is built with a development snapshot toolchain and run with that toolchain's own `libswiftCore`, `libswift_Concurrency` and `libswiftDistributed`, replacing the last with a rebuilt one. A full stdlib build is not needed: `build-libswiftDistributed.sh` compiles `stdlib/public/Distributed` (seven Swift files and one C++ file; two from the cache commit on, which adds the threading error handler the shared library needs on Linux) from a `swiftlang/swift` checkout with the snapshot's own compilers and links it against the snapshot's stdlib. Its Swift flags are the ones the snapshot recorded in its `Distributed.swiftinterface` plus those the Distributed `CMakeLists.txt` and the stdlib's cmake modules add; its C++ flags those of a release runtime build: `-O2 -DNDEBUG`, no exceptions or RTTI, hidden visibility, and the defines `AddSwiftStdlib.cmake` emits for a macOS stdlib build with the defaults of `StdlibOptions.cmake` (of its `SWIFT_STDLIB_*` and `SWIFT_CONCURRENCY_*` defines, the headers the C++ file includes test `SWIFT_STDLIB_HAS_DARWIN_LIBMALLOC`, which has `Runtime/Concurrent.h` size the hash map storage the cache uses with `malloc_good_size`, and `SWIFT_CONCURRENCY_USES_DISPATCH` in `ABI/Task.h`; the others are passed for fidelity). The Swift sources are compiled with the flags the swiftinterface records; of the `-D` conditions the stdlib build adds on the Swift side, Distributed's sources test one, which is off on macOS. The availability macros are derived from `utils/availability-macros.def` as the stdlib build derives them. Every flag is in the script. It builds for arm64 and requires native arm64 macOS, which it checks with `uname -m`.

One line of source is added for the measurement when a revision lacks it. `dispatchToDistributedAccessor` ends in the call into the accessor's async entry, which resumes the caller's context itself, so that call has to be a tail call, and it only is one once the function is inlined into the two `swiftasync` entry points; the branch's last commit marks it `SWIFT_ALWAYS_INLINE`, earlier revisions relied on the optimizer's heuristic. The script compiles the C++ file from a copy to which it adds the attribute when the revision does not carry it (and says so), so that every rebuilt library, the control included, is compiled the same way, and it fails if an out-of-line copy of the function remains in the object or either entry point does not end in the indirect branch into the accessor.

```bash
# TC: the snapshot toolchain's root, the directory holding usr/bin/swiftc and usr/lib/swift/macosx,
#     either an installed /Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-<date>-a.xctoolchain
#     or the Payload directory of `pkgutil --expand-full <snapshot>.pkg <dir>`.
# SRC: a checkout of swiftlang/swift at the revision to build.
"$TC/usr/bin/swift" build -c release --build-path .build-main

# The snapshot's own library, for the baseline:
DYLD_LIBRARY_PATH="$TC/usr/lib/swift/macosx" .build-main/release/ExecuteDistributedTarget timing
DYLD_LIBRARY_PATH="$TC/usr/lib/swift/macosx" .build-main/release/ExecuteDistributedTarget allocations

# A rebuilt one:
TC="$TC" SRC="$SRC" ./build-libswiftDistributed.sh rebuilt
DYLD_LIBRARY_PATH="$PWD/rebuilt/lib:$TC/usr/lib/swift/macosx" .build-main/release/ExecuteDistributedTarget timing
DYLD_LIBRARY_PATH="$PWD/rebuilt/lib:$TC/usr/lib/swift/macosx" .build-main/release/ExecuteDistributedTarget allocations
```

The control, the check that the recipe is right: a library rebuilt from the snapshot's own revision measures the same as the snapshot's own library. In the committed outputs (`results/control-*.txt` against `results/snapshot-*.txt`) the two agree to within 4 instructions per call on three targets and within 99 on the generic target, whose runtime-path median spans 44,251 to 44,551 over the committed runs of the snapshot's own library and 44,251 to 44,350 over those of the control, and the allocations are identical.

## Revisions

- Toolchains: Apple Swift 6.4 (Xcode 27.1, `swiftlang-6.4.0.34.1`), and the main development snapshot `swift-DEVELOPMENT-SNAPSHOT-2026-10-17-a` (Swift 6.5-dev, built from `swiftlang/swift` `f62414fd1d17227`, the control's revision).
- `swiftlang/swift` main at `47a456b8` (2026-10-25), the base of the branch `distributed/cache-target-signature`, published at https://github.com/hassila/swift/tree/distributed/cache-target-signature, four commits:
  - `c44b49ed`: drops the unused `argumentTypes` array and the `utf8CString` conversion of the name (one allocation per call for the no-argument target, two for the others).
  - `34f62d0a`: resolves a target's signature once per accessor record (a `ConcurrentReadableHashMap` keyed by the record, holding the parameter count, the parameter and return type metadata and the generic environment, filled on first use with the same introspection entry points; a generic target still resolves its types per call). The cache is the library's first use of the runtime's threading primitives, so the commit also gives the shared library the runtime's threading objects and adds `ThreadingError.cpp` for their error handler, as `_Concurrency` does, in the stdlib build and in the standalone `Runtimes` build alike; on Darwin neither is reached.
  - `3e22d7a8`: the tests.
  - `61ce96a4`: marks the accessor dispatcher `SWIFT_ALWAYS_INLINE`. Every rebuilt library below carries the attribute, the control included (see the build script), so it is not a variable in any table.

The head outputs in `results/` were measured on a library built from the head `0a5029b3`, those in `results/repeat/` and `results/spread/` on one built from `25e2e937`, the head as it stood during review, before comment and test wording changes, before the threading change was folded into the cache commit and before the last round's changes to that commit's CMake files. The code the script compiles is the same: the library built from `25e2e937` is byte for byte the one built from `52b6d610` (the reviewed form), the one built from `4fa2378a` differs from it only in the error handler, which nothing on Darwin calls, and the one built from `0a5029b3` is byte for byte the one built from `4fa2378a`. Since that run the branch has changed only in the cache commit, in its message and in the standalone build's CMake files (`Runtimes/Core/cmake/interface/SwiftCoreConfig.cmake.in`, `Runtimes/Supplemental/CMakeLists.txt` and `Runtimes/Supplemental/Distributed/CMakeLists.txt`), which the script does not read, so that commit and the two after it have new hashes; the library built from the final head `61ce96a4` is byte for byte the one the head outputs were measured on (sha256 `58fba5b8531c43fca082fa322de581a55092de93012691c7a5399923768ae3b9`). `results/MANIFEST.md` has the machine, the toolchains and the revision and compilers behind every configuration.

To build the measured libraries, in a clone of `swiftlang/swift`:

```bash
git fetch https://github.com/hassila/swift distributed/cache-target-signature   # the repository the branch is published in
git checkout 61ce96a4                                              # the branch head
git checkout c44b49ed                                              # the allocations commit alone
git fetch origin f62414fd1d17227037adf18df53a1dd95f72f1a2 && git checkout FETCH_HEAD   # the control (full hash needed)
```

## Numbers

Apple M4 Max (16 cores, 128 GB), macOS 27.0 (26A428); the full environment and the revision and compilers behind each configuration are recorded in `results/MANIFEST.md`. Each table is the medians of the committed run in `results/<configuration>-timing.txt` and `results/<configuration>-allocations.txt`; a second run of everything is in `results/repeat/`, and further timing runs of the snapshot configurations in `results/spread/`. Those two were taken with an earlier build of the executable, whose hand-written dispatch looked the target's name up in a dictionary inside the measured call, so their hand-written medians read 217 to 448 instructions above those of the committed run. Between the two full runs the runtime path's instruction medians agree to within 111 per call on every target but the branch head's two-`Int` target (7,590 against 8,130, see below), to within 5 on most, and the allocation medians are identical. The committed run was taken on a quiet machine, at the one-minute load average given with each table; the runs in `results/repeat/` and `results/spread/` were taken on a shared machine under a one-minute load average of 11 to 15, and their wall clock is indicative only.

Swift 6.4 as shipped, against the OS library (`results/64-*.txt`; load 2.7):

```text
                 runtime path                              hand-written dispatch (lower bound)
noArgs           22,226 instructions    4 allocations    863 ns    1,352 instructions   0 allocations    53 ns
twoInts          44,216                 8              1,657 ns    1,542                0                63 ns
stringAndArray   54,493                 8              2,009 ns    2,642                0               104 ns
generic          52,039                10              1,968 ns    1,452                0                57 ns
```

Main snapshot 2026-10-17, its own `libswiftDistributed` (already rejecting unknown targets before demangling, swiftlang/swift#92264, and passing the name's byte length, swiftlang/swift#92090) (`results/snapshot-*.txt`; load 2.6):

```text
noArgs           21,309 instructions    4 allocations    759 ns    1,319 instructions   0 allocations    48 ns
twoInts          35,572                 8              1,332 ns    1,493                0                57 ns
stringAndArray   45,170                 8              1,658 ns    2,416                0                90 ns
generic          44,251                10              1,663 ns    1,408                0                51 ns
```

The same snapshot with `libswiftDistributed` rebuilt from its own revision `f62414fd`, the control (`results/control-*.txt`; load 2.6):

```text
noArgs           21,306 instructions    4 allocations    757 ns    1,249 instructions   0 allocations    46 ns
twoInts          35,570                 8              1,288 ns    1,493                0                55 ns
stringAndArray   45,166                 8              1,668 ns    2,416                0                90 ns
generic          44,350                10              1,671 ns    1,408                0                51 ns
```

The same snapshot with `libswiftDistributed` rebuilt from `c44b49ed` alone (fewer allocations; `results/alloc-*.txt`; load 2.7):

```text
noArgs           20,380 instructions    3 allocations    732 ns    1,249 instructions   0 allocations    47 ns
twoInts          34,060                 6              1,334 ns    1,563                0                59 ns
stringAndArray   43,673                 6              1,646 ns    2,486                0                92 ns
generic          42,732                 8              1,616 ns    1,408                0                52 ns
```

The same snapshot with `libswiftDistributed` rebuilt from the branch head (fewer allocations, the signature cache and the explicit inlining; built from `0a5029b3`; `results/head-*.txt`; load 2.7):

```text
noArgs            3,811 instructions    2 allocations    138 ns    1,283 instructions   0 allocations    47 ns
twoInts           7,590                 2                251 ns    1,493                0                56 ns
stringAndArray    8,605                 2                293 ns    2,486                0                91 ns
generic          32,974                 7              1,227 ns    1,408                0                51 ns
```

Runtime path against runtime path, the branch head against the snapshot's own library is the combined effect of the branch: the two-`Int` call goes from 35,572 to 7,590 instructions (4.7 times fewer) and from 8 to 2 allocations, the no-argument call from 21,309 to 3,811 (5.6 times fewer) and from 4 to 2, `String` plus `[Int]` from 45,170 to 8,605 (5.2 times fewer) and from 8 to 2; the generic target keeps its per-call type resolution and goes from 44,251 to 32,974 (1.3 times fewer) and from 10 to 7. The signature cache alone is the branch head against the allocations commit, built with the same flags: the two-`Int` call from 34,060 to 7,590 (4.5 times fewer) and from 6 to 2 allocations, the no-argument call from 20,380 to 3,811 (5.3 times fewer) and from 3 to 2, `String` plus `[Int]` from 43,673 to 8,605 (5.1 times fewer) and from 6 to 2, the generic target from 42,732 to 32,974 (1.3 times fewer) and from 8 to 7. The allocations commit alone saves 929 to 1,519 instructions per call and one allocation for the no-argument target, two for the others. The two allocations left on a non-generic target are the UTF-8 copy of the name and the result buffer.

Two things to know when reading the branch head's figures. Its first timing batch reads 13 % more instructions than the median for the no-argument target and 5 % more for `String` plus `[Int]` (`results/head-timing.txt`), presumably the first resolution of each signature on top of the same lazy metadata work, amortised over the batch as above. And within a process the runtime path's twentieth batch reads within 0.15 % of its median in every committed timing file (only the first, the twentieth and the median are recorded, so this says nothing about the batches in between), with one exception: the head's no-argument target, where the twentieth batch reads 3,673 to 3,674 instructions against a median of 3,811 to 3,812 in every committed head run, 3.6 % lower, for a reason that is not established; the hand-written dispatch of the same target dips the same way in every head run and in no other configuration (its twentieth batch 2.0 to 2.7 % under its median), and that path never enters the runtime, so whatever it is belongs to the process rather than to the signature cache. The hand-written path's twentieth batch is otherwise within 0.8 % of its median, with three files above 0.15 %: the no-argument target in `results/alloc-timing.txt` (1,259 against 1,249), the generic target in `results/spread/alloc-timing-2.txt` (1,720 against 1,716), and `String` plus `[Int]` in `results/spread/alloc-timing-1.txt` (2,757 against 2,752). Between processes an instruction median can differ, most on the two-`Int` target: over all committed timing runs of a configuration it spans 35,572 to 35,962 on the snapshot's own library, 35,569 to 35,707 on the control, 34,060 to 34,195 on the allocations commit and 7,590 to 8,130 on the branch head (7,590 in the committed run, 8,130 in the repeat), the other targets at most 300 on the snapshot's library and 172 on the branch head, and the no-argument and generic targets under 10 on the head. The cause is not established; it shows on the snapshot's own library too, so it is not the signature cache. The ratios above move with it: depending on the pair of runs the two-`Int` call is 4.4 to 4.7 times fewer instructions on the branch head than on the snapshot's library and `String` plus `[Int]` 5.1 to 5.3; the no-argument call stays at 5.6 and the generic target at 1.3 to 1.4.

This follows up swiftlang/swift#92264, whose description notes that the record is "looked up multiple times, even though cached" and promises a follow-up; the signature resolution behind the record is the larger part of that cost.
