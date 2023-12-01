#!/bin/bash

rm -rf build

xcodebuild clean build -project BinaryTreeUI.xcodeproj -scheme 'BinaryTreeUI Optimized' -arch arm64 -derivedDataPath build -skipPackagePluginValidation -skipMacroValidation MARKETING_VERSION=0.0.1 CURRENT_PROJECT_VERSION=0.0.1 > build_log 2>&1
if grep -q "profile-generate" build_log; then
	echo "Code coverage in build log"
fi

open build/Build/Products/Release/BinaryTreeUI.app
