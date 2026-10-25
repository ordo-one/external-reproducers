#!/bin/sh
# Rebuilds libswiftDistributed.dylib from a swiftlang/swift checkout with a main development snapshot
# toolchain, against that toolchain's own libswiftCore and libswift_Concurrency, so a change to the
# Distributed library can be measured without a full stdlib build.
#
#   TC=/path/to/expanded-snapshot SRC=/path/to/swiftlang/swift ./build-libswiftDistributed.sh [OUT]
#
#   TC   the snapshot toolchain's root (the directory holding usr/bin/swiftc and usr/lib/swift/macosx);
#        an installed one is /Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-<date>-a.xctoolchain,
#        an expanded one is the Payload directory of `pkgutil --expand-full <snapshot>.pkg <dir>`
#   SRC  a checkout of swiftlang/swift at the revision to build
#   OUT  the output directory, default ./rebuilt; the library lands in OUT/lib/libswiftDistributed.dylib
#
# Native arm64 macOS only (the target triple below is arm64). Run the executable with
# DYLD_LIBRARY_PATH=OUT/lib:TC/usr/lib/swift/macosx.
#
# The Swift flags are the ones the snapshot recorded in its own Distributed.swiftinterface
# (`swift-module-flags:`), plus those stdlib/public/Distributed/CMakeLists.txt adds, plus the stdlib's
# whole-module and SIL flags from stdlib/cmake/modules; the availability macros are derived from
# utils/availability-macros.def the way AddSwiftStdlib.cmake derives them for the macOS stdlib
# (deployment version 13.0). The C++ file is compiled as a release runtime build does: -O2 -DNDEBUG,
# no exceptions or RTTI, hidden visibility, and the defines AddSwiftStdlib.cmake's
# _add_target_variant_c_compile_flags emits for a macOS stdlib build with the defaults of
# stdlib/cmake/modules/StdlibOptions.cmake (SWIFT_OBJC_INTEROP is not passed, as there: Config.h
# derives it on Apple platforms). Of the SWIFT_STDLIB_* and SWIFT_CONCURRENCY_* defines the headers
# DistributedActor.cpp includes test SWIFT_STDLIB_HAS_DARWIN_LIBMALLOC (Runtime/Concurrent.h sizes a hash
# map's storage with malloc_good_size) and SWIFT_CONCURRENCY_USES_DISPATCH (ABI/Task.h); the rest are
# passed for fidelity.
#
# `dispatchToDistributedAccessor` ends in the call into the accessor's async entry, which resumes the
# caller's context itself, so that call has to be a tail call, and it only is one once the function
# is inlined into the two `swiftasync` entry points. The branch under measurement marks it
# SWIFT_ALWAYS_INLINE in its last commit; revisions before that relied on the optimizer's heuristic.
# So that every rebuilt library is compiled the same way, the C++ file is compiled from a copy in OUT
# to which the attribute is added when the revision lacks it (one line; the script says when it did),
# and the build fails if an out-of-line copy of the function remains or either entry point does not
# end in an indirect branch.
set -eu
: "${TC:?set TC to the root of the snapshot toolchain}"
: "${SRC:?set SRC to a checkout of swiftlang/swift}"

case "$(uname -s)/$(uname -m)" in
  Darwin/arm64) ;;
  *) echo "this script builds for arm64-apple-macosx and must run on native arm64 macOS (uname -m: $(uname -m))" >&2; exit 1 ;;
esac

# Absolute paths before any cd; the Swift sources are compiled from their own directory.
TC="$(cd "$TC" && pwd -P)"
SRC="$(cd "$SRC" && pwd -P)"
OUT="${1:-rebuilt}"
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd -P)"
SDK="$(xcrun --show-sdk-path)"
mkdir -p "$OUT/lib" "$OUT/include/swift/Runtime"

cat > "$OUT/include/swift/Runtime/CMakeConfig.h" <<'EOF'
#ifndef SWIFT_RUNTIME_CMAKECONFIG_H
#define SWIFT_RUNTIME_CMAKECONFIG_H
#define SWIFT_VERSION_MAJOR "6"
#define SWIFT_VERSION_MINOR "5"
#endif
EOF

python3 -I - "$SRC/utils/availability-macros.def" > "$OUT/availability.rsp" <<'EOF'
import re, sys
for line in open(sys.argv[1]):
    line = line.strip()
    if not line or line.startswith('#'):
        continue
    print(f'-Xfrontend -define-availability -Xfrontend "{line}"')
    if line.startswith('SwiftStdlib '):
        current = line.replace('SwiftStdlib', 'StdlibDeploymentTarget', 1)
        m = re.search(r'macOS (\d+(\.\d+)+)', line) or re.search(r'anyAppleOS (\d+(\.\d+)+)', line)
        if m and m.group(1) != '9999':
            parts = [int(x) for x in m.group(1).split('.')]
            if parts > [13, 0]:
                current = re.sub(r':.*', ':macOS 13.0', current)
        print(f'-Xfrontend -define-availability -Xfrontend "{current}"')
EOF

# The C++ file, with the accessor dispatcher marked SWIFT_ALWAYS_INLINE when the revision does not.
CPP="$OUT/DistributedActor.cpp"
cp "$SRC/stdlib/public/Distributed/DistributedActor.cpp" "$CPP"
if ! grep -q -B1 '^static void dispatchToDistributedAccessor(' "$CPP" || \
   ! grep -B1 '^static void dispatchToDistributedAccessor(' "$CPP" | grep -q '^SWIFT_ALWAYS_INLINE'; then
  python3 -I - "$CPP" <<'EOF'
import sys
path = sys.argv[1]
text = open(path).read()
needle = 'static void dispatchToDistributedAccessor('
assert text.count(needle) == 1, 'expected one definition of dispatchToDistributedAccessor'
open(path, 'w').write(text.replace(needle, 'SWIFT_ALWAYS_INLINE\n' + needle, 1))
EOF
  echo "added SWIFT_ALWAYS_INLINE to dispatchToDistributedAccessor (this revision does not carry it)"
fi

"$TC/usr/bin/clang++" -c "$CPP" -o "$OUT/DistributedActor.o" \
  -std=c++17 -O2 -DNDEBUG \
  -fno-exceptions -fno-rtti -fvisibility=hidden -fvisibility-inlines-hidden \
  -target arm64-apple-macosx13.0 -isysroot "$SDK" \
  -I "$OUT/include" -I "$SRC/include" -I "$SRC/stdlib/include" -I "$SRC/stdlib/public/SwiftShims" -I "$SRC/stdlib/public" \
  -DSWIFT_RUNTIME -DSWIFT_LIB_SUBDIR='"macosx"' -DSWIFT_ARCH='"arm64"' \
  -DSWIFT_TARGET_LIBRARY_NAME=swiftDistributed -DswiftDistributed_EXPORTS \
  -DSWIFT_LIBRARY_EVOLUTION=1 -DSWIFT_STDLIB_SUPPORT_BACK_DEPLOYMENT -DSWIFT_ENABLE_REFLECTION \
  -DSWIFT_STDLIB_HAS_DLADDR -DSWIFT_STDLIB_HAS_DLSYM=1 -DSWIFT_STDLIB_HAS_FILESYSTEM \
  -DSWIFT_STDLIB_HAS_DARWIN_LIBMALLOC=1 -DSWIFT_STDLIB_HAS_ASL -DSWIFT_STDLIB_HAS_STDIN \
  -DSWIFT_STDLIB_HAS_ENVIRON -DSWIFT_STDLIB_HAS_LOCALE -DSWIFT_CONCURRENCY_USES_DISPATCH \
  -DSWIFT_THREADING_DARWIN -DSWIFT_RUNTIME_OS_VERSIONING -DSWIFT_STDLIB_SHORT_MANGLING_LOOKUPS \
  -DSWIFT_STDLIB_ENABLE_VECTOR_TYPES -DSWIFT_STDLIB_HAS_TYPE_PRINTING \
  -DSWIFT_STDLIB_SUPPORTS_BACKTRACE_REPORTING -DSWIFT_STDLIB_ENABLE_UNICODE_DATA \
  -DSWIFT_STDLIB_TRACING -DSWIFT_STDLIB_OVERRIDABLE_RETAIN_RELEASE

# The objects the library is linked from, collected in the positional parameters so that paths with
# spaces survive. The threading error handler is the one the cache commit adds beside
# DistributedActor.cpp (revisions before it have none). On Darwin nothing in the library calls it; it
# is compiled so that the library has the same objects as the stdlib build's.
set -- "$OUT/DistributedActor.o"
if [ -f "$SRC/stdlib/public/Distributed/ThreadingError.cpp" ]; then
  "$TC/usr/bin/clang++" -c "$SRC/stdlib/public/Distributed/ThreadingError.cpp" -o "$OUT/ThreadingError.o" \
    -std=c++17 -O2 -DNDEBUG \
    -fno-exceptions -fno-rtti -fvisibility=hidden -fvisibility-inlines-hidden \
    -target arm64-apple-macosx13.0 -isysroot "$SDK" \
    -I "$OUT/include" -I "$SRC/include" -I "$SRC/stdlib/include" -I "$SRC/stdlib/public/SwiftShims" -I "$SRC/stdlib/public" \
    -DSWIFT_RUNTIME -DSWIFT_TARGET_LIBRARY_NAME=swiftDistributed -DswiftDistributed_EXPORTS -DSWIFT_THREADING_DARWIN
  set -- "$@" "$OUT/ThreadingError.o"
  echo "compiled ThreadingError.cpp (this revision carries it)"
fi

# The dispatcher must have been inlined into both entry points, and each must end in the indirect
# branch into the accessor.
if nm "$OUT/DistributedActor.o" | grep -q dispatchToDistributedAccessor; then
  echo "dispatchToDistributedAccessor was not inlined into the entry points" >&2
  exit 1
fi
otool -tv "$OUT/DistributedActor.o" | awk '
  /^_swift_distributed_execute_target(_with_isolation)?:$/ { flush(); name = $1; next }
  /^[^ \t].*:$/ { flush(); next }
  name != "" && NF >= 2 { last = $2 }
  function flush() { if (name != "") { print name, last; name = ""; last = "" } }
  END { flush() }
' > "$OUT/entry-points.txt"
if [ "$(wc -l < "$OUT/entry-points.txt")" -ne 2 ] || grep -v -q ' br$' "$OUT/entry-points.txt"; then
  echo "an entry point does not end in a tail branch into the accessor:" >&2
  cat "$OUT/entry-points.txt" >&2
  exit 1
fi

cd "$SRC/stdlib/public/Distributed"
"$TC/usr/bin/swiftc" -emit-library -emit-module -module-name Distributed \
  -o "$OUT/lib/libswiftDistributed.dylib" -emit-module-path "$OUT/Distributed.swiftmodule" \
  -target arm64-apple-macosx13.0 -sdk "$SDK" \
  -resource-dir "$TC/usr/lib/swift" -L "$TC/usr/lib/swift/macosx" \
  -Xlinker -install_name -Xlinker @rpath/libswiftDistributed.dylib \
  -parse-stdlib -language-mode 5 -O -wmo -enable-library-evolution -library-level api \
  -module-link-name swiftDistributed -runtime-compatibility-version none \
  -Xfrontend -enforce-exclusivity=unchecked -Xfrontend -target-min-inlining-version -Xfrontend min \
  -Xfrontend -disable-implicit-concurrency-module-import \
  -Xfrontend -disable-implicit-string-processing-module-import \
  -Xfrontend -prespecialize-generic-metadata -Xfrontend -enable-ossa-modules \
  -Xfrontend -disable-objc-attr-requires-foundation-module \
  -enable-experimental-feature SuppressedAssociatedTypesWithDefaults \
  -enable-experimental-feature NonescapableTypes -enable-experimental-feature Lifetimes \
  -enable-experimental-feature AddressableParameters -enable-upcoming-feature MemberImportVisibility \
  -enable-experimental-feature AllowUnsafeAttribute -strict-memory-safety \
  -Xfrontend -enable-sil-opaque-values \
  -warn-implicit-overrides \
  @"$OUT/availability.rsp" \
  DistributedActor.swift DistributedActorSystem.swift DistributedAssertions.swift \
  DistributedDefaultExecutor.swift DistributedMacros.swift DistributedMetadata.swift \
  LocalTestingDistributedActorSystem.swift \
  "$@" \
  -lswiftCore -lswift_Concurrency

echo "built $OUT/lib/libswiftDistributed.dylib from $(git -C "$SRC" rev-parse --short HEAD 2>/dev/null || echo "$SRC")"
