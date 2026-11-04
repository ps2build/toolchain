#!/bin/bash
# EE newlib-nano: built into a scratch prefix, then libc/libg/libm are renamed into place.

source "$(dirname "$0")/../../lib/common.sh"
source "$(dirname "$0")/../config.sh"

fetch_source "$NEWLIB_URL" "$NEWLIB_REF" "$1"
cd "$REPO_FOLDER"

prepare_build_env

TARGET="mips64r5900el-ps2-elf"
TARGET_CFLAGS="-DPREFER_SIZE_OVER_SPEED=1 -Os -gdwarf-2 -gz"
SCRATCH_PREFIX="$PWD/nano-prefix"

rm -rf "$SCRATCH_PREFIX"
mkdir "$SCRATCH_PREFIX"

rm -rf "build-$TARGET"
mkdir "build-$TARGET"
cd "build-$TARGET"

CFLAGS_FOR_TARGET="$TARGET_CFLAGS" \
../configure \
  --prefix="$SCRATCH_PREFIX/ee" \
  --target="$TARGET" \
  --with-sysroot="$PS2DEV/ee/$TARGET" \
  --disable-newlib-supplied-syscalls \
  --enable-newlib-reent-small \
  --disable-newlib-fvwrite-in-streamio \
  --disable-newlib-fseek-optimization \
  --disable-newlib-wide-orient \
  --enable-newlib-nano-malloc \
  --disable-newlib-unbuf-stream-opt \
  --enable-lite-exit \
  --enable-newlib-global-atexit \
  --enable-newlib-nano-formatted-io \
  --enable-newlib-retargetable-locking \
  --enable-newlib-multithread \
  --disable-nls

make --quiet -j "$PROC_NR" all
make --quiet -j "$PROC_NR" install-strip

mv "$SCRATCH_PREFIX/ee/$TARGET/lib/libc.a" "$PS2DEV/ee/$TARGET/lib/libc_nano.a"
mv "$SCRATCH_PREFIX/ee/$TARGET/lib/libg.a" "$PS2DEV/ee/$TARGET/lib/libg_nano.a"
mv "$SCRATCH_PREFIX/ee/$TARGET/lib/libm.a" "$PS2DEV/ee/$TARGET/lib/libm_nano.a"
