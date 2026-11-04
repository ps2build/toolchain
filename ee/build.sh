#!/bin/bash

# EE (Emotion Engine) toolchain: binutils, then a two-stage GCC bootstrap around newlib. Arguments are step numbers to re-run, e.g. ./build.sh 3.
set -e
TARGET_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$TARGET_DIR"

source "../lib/common.sh"
source "config.sh"

run_build ee \
  "$BINUTILS_URL" "$BINUTILS_REF" \
  "$GCC_URL" "$GCC_REF" \
  "$NEWLIB_URL" "$NEWLIB_REF" \
  "$PTHREAD_EMBEDDED_URL" "$PTHREAD_EMBEDDED_REF" \
  -- "$@"
