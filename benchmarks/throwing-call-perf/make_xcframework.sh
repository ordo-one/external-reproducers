#!/bin/bash

set -euo pipefail
set -x

xcodegen generate

LIBRARY_NAME=ThrowingCallPerf
MODULE_NAME=ThrowingCallPerf
OUTPUT_NAME=${LIBRARY_NAME}-macOS.xcframework

rm -rf archives

for platform in 'macOS' ; do
    xcodebuild archive \
        -scheme ${MODULE_NAME}_${platform%% *} \
        -destination "generic/platform=${platform}" \
        -archivePath "archives/${platform// /_}.xcarchive"
done

rm -rf "${OUTPUT_NAME}"

xcodebuild -create-xcframework \
    -archive archives/macOS.xcarchive -framework ${MODULE_NAME}.framework \
    -output "${OUTPUT_NAME}"

zip --symlinks -r "${OUTPUT_NAME}.zip" "${OUTPUT_NAME}"

