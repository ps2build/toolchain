#!/bin/bash
# EE GCC stage 1: C-only bootstrap compiler used to build newlib.

source "$(dirname "$0")/../../lib/common.sh"
source "$(dirname "$0")/../config.sh"

fetch_source "$GCC_URL" "$GCC_REF" "$1"
cd "$REPO_FOLDER"

prepare_build_env
macos_extra_configure_opts

TARGET="mips64r5900el-ps2-elf"
TARGET_CFLAGS="-O2 -gdwarf-2 -gz"

rm -rf "build-$TARGET-stage1"
mkdir "build-$TARGET-stage1"
cd "build-$TARGET-stage1"

CFLAGS_FOR_TARGET="$TARGET_CFLAGS" \
# keeps u8"" literals as const char[] so libcody builds with C++20 host compilers
CXXFLAGS="-g -O1 -fno-char8_t" \
CXXFLAGS_FOR_BUILD="-g -O1 -fno-char8_t" \
../configure \
  --quiet \
  --prefix="$PS2DEV/ee" \
  --target="$TARGET" \
  --enable-languages="c" \
  --with-float=hard \
  --without-headers \
  --without-newlib \
  --disable-libgcc \
  --disable-shared \
  --disable-threads \
  --disable-multilib \
  --disable-libatomic \
  --disable-nls \
  --disable-tls \
  --disable-libssp \
  --disable-libgomp \
  --disable-libmudflap \
  --disable-libquadmath \
  --without-zstd \
  $TARG_XTRA_OPTS

make --quiet -j "$PROC_NR" all-gcc
make --quiet -j "$PROC_NR" install-gcc
