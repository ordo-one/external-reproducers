# Description:

## Step to prepare:
- Checkout three packges: `Api`, `Lib`, `Exec`
- Build `Lib` package using: `swift build`, debug build is enough
- Build `Exec` package using: `swift build; swift build -c release`.

## Test description:


## Test case `Specific`:
This test case works as intended in both debug and release modes. The test loads `Lib` library dynamicallt and instantita instace of pluging:
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
