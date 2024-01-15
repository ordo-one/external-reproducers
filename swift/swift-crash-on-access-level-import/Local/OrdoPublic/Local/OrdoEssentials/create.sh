
function create_xcf() {
    local name="${1}"

    rm -rf ${name}.xcframework/macos-arm64_x86_64/

    echo "Generating XCF for ${name}"

    xcodebuild archive -configuration Release -scheme ${name} -destination "generic/platform=macOS" -archivePath ${name}.xcarchive -derivedDataPath ${name}.derived SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    if [ $? -ne 0 ]; then
        echo "Build failed"
        exit -1
    fi

    mkdir ${name}.xcarchive/Products/usr/local/lib/${name}.framework/Modules
    cp -r ${name}.derived/Build/Intermediates.noindex/ArchiveIntermediates/${name}/BuildProductsPath/Release/${name}.swiftmodule ${name}.xcarchive/Products/usr/local/lib/${name}.framework/Modules/${name}.swiftmodule

    xcodebuild -create-xcframework \
        -framework ${name}.xcarchive/Products/usr/local/lib/${name}.framework \
        -output ${name}.xcframework

    if [ $? -ne 0 ]; then
        echo "Build failed"
        exit -1
    fi

    rm -rf ${name}.xcarchive
    rm -rf ${name}.derived
}

create_xcf OrdoEssentials
