#!/bin/bash
# EE newlib.

source "$(dirname "$0")/../../lib/common.sh"
source "$(dirname "$0")/../config.sh"

fetch_source "$NEWLIB_URL" "$NEWLIB_REF" "$1"
cd "$REPO_FOLDER"

prepare_build_env

TARGET="mips64r5900el-ps2-elf"
TARGET_CFLAGS="-O2 -gdwarf-2 -gz"

rm -rf "build-$TARGET"
mkdir "build-$TARGET"
cd "build-$TARGET"

CFLAGS_FOR_TARGET="$TARGET_CFLAGS" \
../configure \
  --prefix="$PS2DEV/ee" \
  --target="$TARGET" \
  --with-sysroot="$PS2DEV/ee/$TARGET" \
  --enable-newlib-retargetable-locking \
  --enable-newlib-multithread \
  --enable-newlib-io-c99-formats

make --quiet -j "$PROC_NR" all
make --quiet -j "$PROC_NR" install-strip
