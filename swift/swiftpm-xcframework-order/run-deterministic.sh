#!/bin/bash
# Same as run.sh's plugin invocations, but with deterministic Swift hashing in the
# swift-package host process. If the ordering comes from hash-seeded Set/Dictionary
# iteration, every plan (and every process) produces the same manifest.
set -uo pipefail
cd "$(dirname "$0")"
export SWIFT_DETERMINISTIC_HASHING=1
for n in A B; do
  echo "===== SWIFT_DETERMINISTIC_HASHING=1, invocation $n"
  swift package build-twice 2>&1 | grep -E '^build #|Core compile inputs|^RESULT'
done
