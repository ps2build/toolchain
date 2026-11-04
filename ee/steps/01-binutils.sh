#!/bin/bash
# EE binutils.

source "$(dirname "$0")/../../lib/common.sh"
source "$(dirname "$0")/../config.sh"

fetch_source "$BINUTILS_URL" "$BINUTILS_REF" "$1"
cd "$REPO_FOLDER"

prepare_build_env
macos_extra_configure_opts
cross_configure_opts

TARGET="mips64r5900el-ps2-elf"

rm -rf "build-$TARGET"
mkdir "build-$TARGET"
cd "build-$TARGET"

# gdb uses an implicit this capture that GCC 16+ flags under -Werror
CXXFLAGS="-Wno-error=deprecated" \
../configure \
  --quiet \
  --prefix="$PS2DEV/ee" \
  --target="$TARGET" \
  --with-sysroot="$PS2DEV/ee/$TARGET" \
  --disable-separate-code \
  --disable-sim \
  --disable-nls \
  --disable-gdb \
  --with-python=no \
  --without-zstd \
  $TARG_XTRA_OPTS \
  $CROSS_XTRA_OPTS

make --quiet -j "$PROC_NR"
make --quiet -j "$PROC_NR" install-strip
