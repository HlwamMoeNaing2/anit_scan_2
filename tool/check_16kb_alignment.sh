#!/bin/sh
# Checks that 64-bit native libraries inside an APK or AAB are aligned for
# 16 KB memory pages. Usage:
#   tool/check_16kb_alignment.sh build/app/outputs/flutter-apk/app-release.apk
set -eu

archive=${1:?Pass a release APK or AAB}
sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
ndk="$sdk/ndk/28.2.13676358"
readobj="$ndk/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-readobj"

if [ ! -x "$readobj" ]; then
  echo "llvm-readobj not found at $readobj"
  exit 1
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
unzip -q "$archive" -d "$work"

failed=0
found=0
for abi in arm64-v8a x86_64; do
  dir="$work/lib/$abi"
  if [ ! -d "$dir" ]; then
    dir="$work/base/lib/$abi"
  fi
  if [ ! -d "$dir" ]; then
    continue
  fi
  for so in "$dir"/*.so; do
    [ -f "$so" ] || continue
    found=$((found + 1))
    # LOAD segment alignment is printed as "Alignment: N".
    min=$(
      "$readobj" --program-headers "$so" |
        awk '/Type: PT_LOAD/,/Alignment:/ { if ($1 == "Alignment:") print $2 }' |
        sort -n |
        head -n 1
    )
    name=$(basename "$so")
    if [ -z "$min" ] || [ "$min" -lt 16384 ]; then
      echo "FAIL $abi/$name alignment ${min:-unknown}"
      failed=1
    else
      echo "OK   $abi/$name alignment $min"
    fi
  done
done

if [ "$found" -eq 0 ]; then
  echo "No arm64-v8a or x86_64 libraries found in $archive"
  exit 1
fi

exit "$failed"
