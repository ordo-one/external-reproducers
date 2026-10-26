# Measurement manifest

Where the committed outputs in this directory were taken, and what built the code behind each configuration.

## Machine

- Apple M4 Max, 16 cores (12 performance, 4 efficiency), 128 GB, arm64.
- macOS 27.0, build 26A428.
- The committed run in this directory was taken on 2026-10-26 from 05:13 to 05:14 on a quiet machine with nothing else running (one-minute load average 2.57 to 2.70); the runs in `repeat/` and `spread/` were taken on a shared, loaded machine (one-minute load average 11 to 15), where the wall clock figures are indicative only. Every output file carries the one-minute, five-minute and fifteen-minute load averages at its start and end. The allocation medians agree across every run of a configuration; the instruction medians vary between processes on some targets, as the README describes under the numbers (both counters are process-wide, so whatever else the process's threads do is counted too).

## Toolchains

- Xcode 27.1 (build 27A9275): Apple Swift version 6.4 (`swiftlang-6.4.0.34.1 clang-2100.3.34.1`), swift-driver 1.168.6. Builds the `64` executable, which runs against the `libswiftDistributed` of macOS 27.0 (26A428).
- `swift-DEVELOPMENT-SNAPSHOT-2026-10-17-a` (bundle `org.swift.65202610171a`): Apple Swift version 6.5-dev (LLVM `9b3700c0bd7ce7a`, Swift `f62414fd1d17227`), Apple clang version 23.0.0 (`swiftlang/llvm-project` `9b3700c0bd7ce7a316be346fec8f2fd78ea0ab8a`). Builds the `.build-main` executable and every rebuilt library: the snapshot's `swiftc` compiles the Swift files and links the library, its `clang++` compiles the C++ files.

## Configurations

Each configuration is one timing process and one allocation-counting process, `<configuration>-timing.txt` and `<configuration>-allocations.txt`. Every rebuilt library was built once with `build-libswiftDistributed.sh` from a `git archive` of the revision named. The `control` and `alloc` libraries were built before the runs in `repeat/` and `spread/` and not rebuilt since, so one build of each served every run of its configuration, the committed run included; the `head` library of the committed run was built from `0a5029b3`, the branch head at the time, and the one behind `repeat/` and `spread/` from `25e2e937` (see below). The executables of the committed run were built fresh for it from this directory's sources. Those behind `repeat/` and `spread/` were built from an earlier `main.swift`, whose hand-written path looked the target's name up in a dictionary inside the measured call, which is why their hand-written medians read 217 to 448 instructions above those of the committed run.

| Configuration | Executable | `libswiftDistributed` | `swiftlang/swift` revision compiled |
|---|---|---|---|
| `64` | Xcode 27.1, Swift 6.4 | the OS library, macOS 27.0 (26A428) | none (shipped binary) |
| `snapshot` | snapshot 2026-10-17 | the snapshot's own | none (shipped binary, the snapshot's `f62414fd1d17227`) |
| `control` | snapshot 2026-10-17 | rebuilt with the snapshot's compilers | `f62414fd1d17227037adf18df53a1dd95f72f1a2`, the snapshot's own revision |
| `alloc` | snapshot 2026-10-17 | rebuilt with the snapshot's compilers | `c44b49ed`, the allocations commit alone on main `47a456b8` |
| `head` | snapshot 2026-10-17 | rebuilt with the snapshot's compilers | `0a5029b3` (`repeat/` and `spread/`: `25e2e937`), see below |

The `control` and `alloc` libraries were compiled with `SWIFT_ALWAYS_INLINE` added to `dispatchToDistributedAccessor` by the script, since those revisions do not carry it; the `head` libraries carry it in their source.

## The head revision

The branch `distributed/cache-target-signature` published for review has the head `61ce96a4` (commits `c44b49ed`, `34f62d0a`, `3e22d7a8`, `61ce96a4` on main `47a456b8`). The committed `head-*.txt` were measured on a library built from `0a5029b3`, the head at the time of that run (commits `c44b49ed`, `eb98da15`, `628153b1`, `0a5029b3`); `repeat/head-*.txt` and `spread/head-timing-*.txt` on one built from `25e2e937`, the head as it stood during review. Between `25e2e937` and `0a5029b3` the branch changed in comment wording in `DistributedActor.cpp`, in two tests and in one CMake file, in commit messages, in the threading change folded into the cache commit after a review finding (`stdlib/public/Distributed/CMakeLists.txt` and `Runtimes/Supplemental/Distributed/CMakeLists.txt` give the shared library the runtime's threading objects, and the new `stdlib/public/Distributed/ThreadingError.cpp` supplies the threading error handler the shared library needs on Linux, where `libswiftCore` does not export it), and in those two CMake files again after a second round (the standalone build chooses its threading package as Core's defaults do and builds its threading objects for shared libraries only). None of that reaches the measured code: the library the script builds from `25e2e937` is byte for byte the one it builds from `52b6d610` (the reviewed form with the final comments), the one it builds from `4fa2378a` differs from those only in the added handler, which nothing on Darwin calls (with addresses normalised, the `otool -tv` disassemblies differ in that one function and in the page operands of seven `adrp` instructions that moved with the literal pool, and both entry points are identical), and the one it builds from `0a5029b3` is byte for byte the one it builds from `4fa2378a`. Since the committed run the branch has changed only in the cache commit: in its message and in the standalone build's CMake files (`Runtimes/Core/cmake/interface/SwiftCoreConfig.cmake.in`, `Runtimes/Supplemental/CMakeLists.txt` and `Runtimes/Supplemental/Distributed/CMakeLists.txt`), which the script does not read. That commit and the two after it took new hashes (`eb98da15` is now `34f62d0a`, `628153b1` is `3e22d7a8` and `0a5029b3` is `61ce96a4`, the last two the same changes as before), and the library the script builds from the final head `61ce96a4` is byte for byte the one it builds from `0a5029b3` (sha256 `58fba5b8531c43fca082fa322de581a55092de93012691c7a5399923768ae3b9`).
