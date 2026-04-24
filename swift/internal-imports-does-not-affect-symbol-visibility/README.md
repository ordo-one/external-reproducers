# `internal import` does not restrict symbol visibility in dynamic libraries

## Summary

When two dynamic libraries both use `internal import SharedLib`, they still
each emit and export the symbols of the public types they reference from
`SharedLib`. On Darwin, the ObjC runtime notices the duplicate class records
when both dylibs get loaded into the same process and prints:

```
objc[…]: Class _TtC9SharedLib11PublicThing is implemented in both …/libPluginA.dylib
    and …/libPluginB.dylib. This may cause spurious casting failures and mysterious
    crashes. One of the duplicates must be removed or renamed.
```

Intuitively, `internal import SharedLib` should confine `SharedLib`'s types
to the importing module. In practice they leak into the dylib's exported
symbol table, turning every shared dependency into a duplicate-class hazard
when plugins are co-loaded via `dlopen`.

Reduced from the real-world issue observed in `plugin-trading-quoter`, where
classes from `OrdoPluginMetadata` collided between `libQuoteStatus.dylib`
and `libQuoterEndpoints.dylib` after `ordo plugin build && ordo plugin install`.

## Layout

```
.
├── Package.swift              — two dynamic library products + Loader executable
├── Local/
│   └── SharedLib/             — local package the two dylibs depend on
│       └── Sources/SharedLib/SharedLib.swift
└── Sources/
    ├── PluginA/PluginA.swift  — internal import SharedLib
    ├── PluginB/PluginB.swift  — internal import SharedLib
    └── Loader/main.swift      — dlopen libPluginA.dylib + libPluginB.dylib
```

`SharedLib` exposes a single `public final class PublicThing`. Both plugins
import it via `internal import SharedLib` and instantiate it inside a
`@_cdecl` probe.

## Reproduce

```
swift build
.build/debug/Loader
```

Expected output on `stderr`:

```
objc[…]: Class _TtC9SharedLib11PublicThing is implemented in both …/libPluginA.dylib and …/libPluginB.dylib. …
```

## Confirm symbol duplication without running the loader

```
nm -g .build/debug/libPluginA.dylib | grep SharedLib
nm -g .build/debug/libPluginB.dylib | grep SharedLib
```

Both dylibs export the full set of `$s9SharedLib11PublicThing…` symbols
(metadata, vtable entries, accessors, deinit, etc.), verbatim.

## Environment

- macOS, `arm64-apple-macosx26.0`
- Apple Swift 6.3.1 (swiftlang-6.3.1.1.2, clang-2100.0.123.102)
- `swift-tools-version: 6.2`
