#!/bin/bash

# IOP toolchain: upstream binutils and GCC. Arguments are step numbers to re-run, e.g. ./build.sh 3.
set -e
TARGET_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$TARGET_DIR"

source "../lib/common.sh"
source "config.sh"

run_build iop \
  "$BINUTILS_URL" "$BINUTILS_REF" \
  "$GCC_URL" "$GCC_REF" \
  -- "$@"
