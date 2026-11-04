#!/bin/bash
# EE GCC stage 2: full C/C++ compiler against newlib.

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

TARGET="mips64r5900el-ps2-elf"
TARGET_CFLAGS="-O2 -gdwarf-2 -gz"

if test -n "$PS2_CROSS_HOST" && test -n "$PS2_NATIVE_EE_TOOLS"; then
  TARGET_CFLAGS="$TARGET_CFLAGS --sysroot=$PS2DEV/ee/$TARGET"

  use_native_gcc "$TARGET" "$PS2_NATIVE_EE_TOOLS" "$(pwd)/native-ee-wrapper-bin"
fi

# GCC's build needs GNU sed on macOS
if test "$(uname -s)" = "Darwin"; then
  mkdir -p "gnu-sed-shim"
  ln -sf "$(which gsed)" "gnu-sed-shim/sed"
  export PATH="$(realpath gnu-sed-shim):$PATH"
fi

rm -rf "build-$TARGET-stage2"
mkdir "build-$TARGET-stage2"
cd "build-$TARGET-stage2"

CFLAGS_FOR_TARGET="$TARGET_CFLAGS" \
CXXFLAGS_FOR_TARGET="$TARGET_CFLAGS" \
# keeps u8"" literals as const char[] so libcody builds with C++20 host compilers
CXXFLAGS="-g -O1 -fno-char8_t" \
CXXFLAGS_FOR_BUILD="-g -O1 -fno-char8_t" \
../configure \
  --quiet \
  --prefix="$PS2DEV/ee" \
  --target="$TARGET" \
  --enable-languages="c,c++" \
  --with-float=hard \
  --with-sysroot="$PS2DEV/ee/$TARGET" \
  --with-native-system-header-dir="/include" \
  --with-newlib \
  --disable-libssp \
  --disable-multilib \
  --disable-nls \
  --disable-tls \
  --enable-cxx-flags=-G0 \
  --enable-threads=posix \
  --without-zstd \
  $TARG_XTRA_OPTS \
  $CROSS_XTRA_OPTS

if test -n "$PS2_CROSS_HOST"; then
  make --quiet -j "$PROC_NR" CPPFLAGS_FOR_TARGET="$TARGET_CFLAGS" all
  make --quiet -j "$PROC_NR" CPPFLAGS_FOR_TARGET="$TARGET_CFLAGS" install-strip
else
  make --quiet -j "$PROC_NR" all
  make --quiet -j "$PROC_NR" install-strip
fi
