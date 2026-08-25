#!/bin/bash
# Reproduction driver:
#  1. generate the xcframeworks
#  2. run the BuildTwice plugin twice (two separate swift-package processes), each building
#     ConsumerA, ConsumerB, ConsumerA through PackageManager.build
#  3. diff the framework-input order of the Core compile command across all snapshots
set -uo pipefail
cd "$(dirname "$0")"
./make-xcframeworks.sh
rm -rf .build

echo; echo "===== invocation 1: swift package build-twice"
swift package build-twice 2>&1 | grep -v -E '^\[[0-9]+/[0-9]+\]|^Compiling|^Emitting|^Building|^Build complete|^Write|^Copying|^Linking|^Planning'
echo; echo "===== invocation 2: swift package build-twice (fresh process, same sources)"
swift package build-twice 2>&1 | grep -v -E '^\[[0-9]+/[0-9]+\]|^Compiling|^Emitting|^Building|^Build complete|^Write|^Copying|^Linking|^Planning'

echo; echo "===== Core compile command: framework input order per snapshot"
for f in .build/plugins/BuildTwice/outputs/manifest-*.yaml; do
  printf '%s: ' "$(basename "$f")"
  python3 - "$f" <<'PY'
import re, sys
src = open(sys.argv[1]).read()
m = re.search(r'\n  "C\.Core-arm64-apple-macosx-release\.module":\n(.*?)(?=\n  "|\Z)', src, re.S)
inputs = re.search(r'inputs: \[(.*?)\]', m.group(1), re.S).group(1)
print(' '.join(p.split('/')[-2] for p in re.findall(r'"([^"]*\.framework/)"', inputs)))
PY
done

echo; echo "===== control: swift build -c release twice from the CLI (no plugin)"
time swift build -c release 2>&1 | tail -1
time swift build -c release 2>&1 | tail -1
