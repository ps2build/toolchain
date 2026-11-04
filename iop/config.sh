#!/bin/bash
# Source pins. Point $CONFIG_OVERRIDE at a file that re-exports any of them to override.

BINUTILS_URL="https://github.com/ps2build/binutils-gdb.git"
BINUTILS_REF="binutils-2_45_1"

GCC_URL="https://github.com/ps2build/gcc.git"
GCC_REF="releases/gcc-15.2.0"

if test -n "$CONFIG_OVERRIDE" && test -f "$CONFIG_OVERRIDE"; then
  source "$CONFIG_OVERRIDE"
fi
