#!/bin/sh
# Usage: bundle-licenses.sh <build-dir> <dest-dir>
# Copies the license text of every component built under <build-dir> into <dest-dir>; fails if any is missing.
set -e

BUILD="$1"
DEST="$2"

require_license() {
    if [ ! -f "$1" ]; then
        echo "missing license file: $1" >&2
        exit 1
    fi
    mkdir -p "$(dirname "$2")"
    cp "$1" "$2"
}

require_license "$BUILD/ee/gcc/COPYING3"            "$DEST/ee/gcc-COPYING3-GPLv3.txt"
require_license "$BUILD/ee/gcc/COPYING.RUNTIME"    "$DEST/ee/gcc-COPYING.RUNTIME.txt"
require_license "$BUILD/ee/binutils-gdb/COPYING3"  "$DEST/ee/binutils-COPYING3-GPLv3.txt"
require_license "$BUILD/ee/newlib/COPYING.NEWLIB"  "$DEST/ee/newlib-COPYING.NEWLIB.txt"

require_license "$BUILD/iop/gcc/COPYING3"           "$DEST/iop/gcc-COPYING3-GPLv3.txt"
require_license "$BUILD/iop/gcc/COPYING.RUNTIME"   "$DEST/iop/gcc-COPYING.RUNTIME.txt"
require_license "$BUILD/iop/binutils-gdb/COPYING3" "$DEST/iop/binutils-COPYING3-GPLv3.txt"
