#!/bin/bash
# IOP GCC: freestanding C/C++ compiler without a libc.

source "$(dirname "$0")/../../lib/common.sh"
source "$(dirname "$0")/../config.sh"

fetch_source "$GCC_URL" "$GCC_REF" "$1"
cd "$REPO_FOLDER"

prepare_build_env
macos_extra_configure_opts
cross_configure_opts

# mingw hosts need GMP, MPFR and MPC built from source
if test -n "$PS2_CROSS_HOST"; then
  ./contrib/download_prerequisites
fi

TARGET="mipsel-none-elf"
TARGET_CFLAGS="-O2 -gdwarf-2 -gz"

if test -n "$PS2_CROSS_HOST" && test -n "$PS2_NATIVE_IOP_TOOLS"; then
  use_native_gcc "$TARGET" "$PS2_NATIVE_IOP_TOOLS" "$(pwd)/native-iop-wrapper-bin"
fi

rm -rf "build-$TARGET"
mkdir "build-$TARGET"
cd "build-$TARGET"

CFLAGS_FOR_TARGET="$TARGET_CFLAGS" \
CXXFLAGS_FOR_TARGET="$TARGET_CFLAGS" \
# keeps u8"" literals as const char[] so libcody builds with C++20 host compilers
CXXFLAGS="-g -O1 -fno-char8_t" \
CXXFLAGS_FOR_BUILD="-g -O1 -fno-char8_t" \
../configure \
  --quiet \
  --prefix="$PS2DEV/iop" \
  --target="$TARGET" \
  --enable-languages="c,c++" \
  --with-float=soft \
  --with-headers=no \
  --without-newlib \
  --without-cloog \
  --without-ppl \
  --disable-decimal-float \
  --disable-libada \
  --disable-libatomic \
  --disable-libffi \
  --disable-libgomp \
  --disable-libmudflap \
  --disable-libquadmath \
  --disable-libssp \
  --disable-libstdcxx-pch \
  --disable-multilib \
  --disable-shared \
  --disable-threads \
  --disable-target-libiberty \
  --disable-target-zlib \
  --disable-nls \
  --disable-tls \
  --disable-libstdcxx \
  --without-zstd \
  $TARG_XTRA_OPTS \
  $CROSS_XTRA_OPTS

make --quiet -j "$PROC_NR" all
make --quiet -j "$PROC_NR" install-strip
