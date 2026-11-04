#!/bin/bash
# Source pins. Point $CONFIG_OVERRIDE at a file that re-exports any of them to override.

BINUTILS_URL="https://github.com/ps2build/binutils-gdb.git"
BINUTILS_REF="ee-v2.45.1"

GCC_URL="https://github.com/ps2build/gcc.git"
GCC_REF="ee-v15.2.0"

NEWLIB_URL="https://github.com/ps2build/newlib.git"
NEWLIB_REF="ee-v4.6.0"

PTHREAD_EMBEDDED_URL="https://github.com/ps2build/pthread-embedded.git"
PTHREAD_EMBEDDED_REF="platform_agnostic"

if test -n "$CONFIG_OVERRIDE" && test -f "$CONFIG_OVERRIDE"; then
  source "$CONFIG_OVERRIDE"
fi
