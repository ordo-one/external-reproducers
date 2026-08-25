#!/bin/bash
# Generates six trivial Swift frameworks and wraps each in an .xcframework
# (macOS arm64 only; adjust TARGET for other hosts). No external dependencies.
set -euo pipefail
cd "$(dirname "$0")"
TARGET=${TARGET:-arm64-apple-macosx14.0}
SLICE=${SLICE:-arm64-apple-macos}
rm -rf build XCFrameworks
mkdir -p build XCFrameworks

for name in Alpha Beta Gamma Delta Epsilon Zeta; do
  lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')
  fw="build/$name.framework"
  mkdir -p "$fw/Versions/A/Modules/$name.swiftmodule" "$fw/Versions/A/Headers" "$fw/Versions/A/Resources"
  printf 'public func %s() -> Int { %d }\n' "$lower" "${#name}" > "build/$name.swift"

  swiftc -target "$TARGET" -O -parse-as-library -module-name "$name" \
    -emit-library -o "$fw/Versions/A/$name" \
    -emit-module -emit-module-path "$fw/Versions/A/Modules/$name.swiftmodule/$SLICE.swiftmodule" \
    -enable-library-evolution \
    -emit-module-interface-path "$fw/Versions/A/Modules/$name.swiftmodule/$SLICE.swiftinterface" \
    -Xlinker -install_name -Xlinker "@rpath/$name.framework/Versions/A/$name" \
    "build/$name.swift"

  cat > "$fw/Versions/A/Resources/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleExecutable</key><string>$name</string>
  <key>CFBundleIdentifier</key><string>repro.$name</string>
  <key>CFBundleName</key><string>$name</string>
  <key>CFBundlePackageType</key><string>FMWK</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleSupportedPlatforms</key><array><string>MacOSX</string></array>
  <key>LSMinimumSystemVersion</key><string>14.0</string>
</dict></plist>
PLIST

  ln -s A "$fw/Versions/Current"
  ln -s "Versions/Current/$name" "$fw/$name"
  ln -s Versions/Current/Modules "$fw/Modules"
  ln -s Versions/Current/Headers "$fw/Headers"
  ln -s Versions/Current/Resources "$fw/Resources"

  xcodebuild -create-xcframework -framework "$fw" -output "XCFrameworks/$name.xcframework" > /dev/null
  echo "created XCFrameworks/$name.xcframework"
done
