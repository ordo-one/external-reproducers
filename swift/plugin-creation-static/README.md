# Description

## Step to prepare
- Checkout three packges: `Api`, `Lib`, `Exec`
- Build `Lib` package using: `swift build`, debug build is enough
- Build `Exec` package using: `swift build; swift build -c release`.
- Run `Exec` executable with three different modes: `--specific`, `--any`, `--generic`

## Test description
Tests loads `Lib` librayr dynamically and instantiate instance of the plugin implemented in package `Lib`. Loading is implemented using [bundle](https://github.com/ordo-one/package-bundle) and [bundle-manager](https://github.com/ordo-one/package-bundle-manager) projects. After library is loaded a Factory is stored in dictionary: `name->factory`. Then test lookup factory by name and try to instantiate a plugin instance.

## Test case `Specific`
This test case works as intended in both debug and release modes:
```
Start test 'specific'
objc[92250]: Class _TtC3Api13PluginFactory is implemented in both /Users/ordo/Dev/Test/external-reproducers/swift/plugin-creation-static/Exec/.build/arm64-apple-macosx/debug/Exec (0x1048f8b20) and /Users/ordo/Dev/Test/external-reproducers/swift/plugin-creation-static/Lib/.build/arm64-apple-macosx/debug/libLib.dylib (0x104c741c8). One of the two will be used. Which one is undefined.
  PluginFactory:init
Plugin 'Lib' has been loaded, let's try to create it:
  MyPlugin:init
  MyPlugin:deinit
Loading done, now let's find and create plugin with name 'Lib'
Found factory of type: Api.PluginFactory, now trying to instantiate
  MyPlugin:init
Done, shutting down
  MyPlugin:deinit
  PluginFactory:deinit
```

## Test case `Any`
The only one difference with test `specific` is a dictionary where plugin factory stored:
`specific`:
```
var factories: [String: PluginFactory] = [:]
```
`any`:
```
var factories: [String: any BundleFactory] = [:]
```
where:
```
public final class PluginFactory: BundleFactory {
...
```
Test crashes with stack:
```
Start test 'any'
objc[93070]: Class _TtC3Api13PluginFactory is implemented in both /Users/ordo/Dev/Test/external-reproducers/swift/plugin-creation-static/Exec/.build/arm64-apple-macosx/debug/Exec (0x1048ccb20) and /Users/ordo/Dev/Test/external-reproducers/swift/plugin-creation-static/Lib/.build/arm64-apple-macosx/debug/libLib.dylib (0x104c481c8). One of the two will be used. Which one is undefined.
  PluginFactory:init
Plugin 'Lib' has been loaded, let's try to create it:
  MyPlugin:init
  MyPlugin:deinit
Loading done, now let's find and create plugin with name 'Lib'
Found factory of type: Api.PluginFactory, now trying to instantiate
[1]    93070 segmentation fault  swift run Exec --any
```
Stack:
```
Thread 1 Crashed:
0   libswiftCore.dylib            	       0x18fc8289c swift::SubstGenericParametersFromMetadata::SubstGenericParametersFromMetadata(swift::TargetMetadata<swift::InProcess> const*) + 28
1   libswiftCore.dylib            	       0x18fc7ee58 swift_getAssociatedTypeWitnessSlowImpl(swift::MetadataRequest, swift::TargetWitnessTable<swift::InProcess>*, swift::TargetMetadata<swift::InProcess> const*, swift::TargetProtocolRequirement<swift::InProcess> const*, swift::TargetProtocolRequirement<swift::InProcess> const*) + 388
2   libswiftCore.dylib            	       0x18fc7d760 swift_getAssociatedTypeWitness + 92
3   Exec                          	       0x10483fae4 AnyLoading.instantiate<A>(plugin:ofType:) + 1204 (AnyLoading.swift:38)
4   Exec                          	       0x10484018c AnyLoading.run() + 356 (AnyLoading.swift:51)
5   Exec                          	       0x104840f89 ExecMain.run() + 1 (Exec.swift:21)
6   Exec                          	       0x104841e79 protocol witness for AsyncParsableCommand.run() in conformance ExecMain + 1
7   Exec                          	       0x10479d77d static AsyncParsableCommand.main() + 1 (AsyncParsableCommand.swift:37)
8   Exec                          	       0x1048414c5 static ExecMain.$main() + 1
9   Exec                          	       0x104842129 async_MainTQ0_ + 1
10  Exec                          	       0x104842271 thunk for @escaping @convention(thin) @async () -> () + 1
11  Exec                          	       0x10484237d partial apply for thunk for @escaping @convention(thin) @async () -> () + 1
12  libswift_Concurrency.dylib    	       0x20d8ae215 completeTaskWithClosure(swift::AsyncContext*, swift::SwiftError*) + 1
```
## Test case `Generic`
This test case stores factories in the same way as test case `any`, but uses a bit different loading function. Instead of using hardcoded factory type for `BundleManager` the function is generic:
```
    /// Generic bundle loader
    func loadPlugins<Factory: BundleFactory>(at path: FilePath, of _: Factory.Type) async throws {
        let bundleManager = try await BundleManager<Factory>(withPath: path, loadBundles: true)
        ...
```
The test case works normally in debug mode, but crashes with the same stack in release mode:
```
$ swift run Exec --generic
Start test 'generic'
objc[93411]: Class _TtC3Api13PluginFactory is implemented in both /Users/ordo/Dev/Test/external-reproducers/swift/plugin-creation-static/Exec/.build/arm64-apple-macosx/debug/Exec (0x100f40b20) and /Users/ordo/Dev/Test/external-reproducers/swift/plugin-creation-static/Lib/.build/arm64-apple-macosx/debug/libLib.dylib (0x1012bc1c8). One of the two will be used. Which one is undefined.
  PluginFactory:init
Plugin 'Lib' has been loaded, let's try to create it:
  MyPlugin:init
  MyPlugin:deinit
Loading done, now let's find and create plugin with name 'Lib'
Found factory of type: Api.PluginFactory, now trying to instantiate
  MyPlugin:init
Done, shutting down
  MyPlugin:deinit
  PluginFactory:deinit
$ swift run -c release Exec --generic
Start test 'generic'
objc[93475]: Class _TtC3Api13PluginFactory is implemented in both /Users/ordo/Dev/Test/external-reproducers/swift/plugin-creation-static/Exec/.build/arm64-apple-macosx/release/Exec (0x1048e8958) and /Users/ordo/Dev/Test/external-reproducers/swift/plugin-creation-static/Lib/.build/arm64-apple-macosx/debug/libLib.dylib (0x104b9c1c8). One of the two will be used. Which one is undefined.
  PluginFactory:init
Plugin 'Lib' has been loaded, let's try to create it:
  MyPlugin:init
  MyPlugin:deinit
Loading done, now let's find and create plugin with name 'Lib'
Found factory of type: Api.PluginFactory, now trying to instantiate
[1]    93475 segmentation fault  swift run -c release Exec --generic
```
Stack:
```
Thread 1 Crashed:
0   libswiftCore.dylib            	       0x18fc8289c swift::SubstGenericParametersFromMetadata::SubstGenericParametersFromMetadata(swift::TargetMetadata<swift::InProcess> const*) + 28
1   libswiftCore.dylib            	       0x18fc7ee58 swift_getAssociatedTypeWitnessSlowImpl(swift::MetadataRequest, swift::TargetWitnessTable<swift::InProcess>*, swift::TargetMetadata<swift::InProcess> const*, swift::TargetProtocolRequirement<swift::InProcess> const*, swift::TargetProtocolRequirement<swift::InProcess> const*) + 388
2   libswiftCore.dylib            	       0x18fc7d760 swift_getAssociatedTypeWitness + 92
3   Exec                          	       0x10489eba0 specialized GenericLoading.instantiate<A>(plugin:ofType:) + 436 (GenericLoading.swift:38)
4   Exec                          	       0x10489e1ec specialized GenericLoading.instantiate<A>(plugin:ofType:) + 16 [inlined]
5   Exec                          	       0x10489e1ec GenericLoading.run() + 156 (GenericLoading.swift:51)
6   Exec                          	       0x10489d1e5 ExecMain.run() + 1 (Exec.swift:27)
7   Exec                          	       0x10489d461 protocol witness for AsyncParsableCommand.run() in conformance ExecMain + 1
8   Exec                          	       0x10483de19 static AsyncParsableCommand.main() + 1 (AsyncParsableCommand.swift:37)
9   Exec                          	       0x10489c805 specialized thunk for @escaping @convention(thin) @async () -> () + 1
10  libswift_Concurrency.dylib    	       0x20d8ae27d completeTaskAndRelease(swift::AsyncContext*, swift::SwiftError*) + 1
```
