# SwiftPM: hash-seeded ordering of binary-target inputs recompiles xcframework dependents on every re-plan

Reproducer for swiftlang/swift-package-manager (see the linked issue). Six trivial xcframeworks, one module importing all of them, two thin dynamic-library products, and a command plugin that builds them through `PackageManager.build` the way a bundling plugin does.

```bash
./run.sh                # generate xcframeworks, run the plugin twice, print framework-input order per plan + CLI control
./run-deterministic.sh  # same with SWIFT_DETERMINISTIC_HASHING=1 — order stable, builds 2/3 are no-ops
```

Requires Xcode command line tools (`swiftc`, `xcodebuild`) on arm64 macOS; set `TARGET`/`SLICE` in `make-xcframeworks.sh` for other hosts.

Bug: `Core` is recompiled on every build with a different framework-input order each plan. Expected: builds 2 and 3 are no-ops.
