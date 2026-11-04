#!/bin/bash
# Removes the placeholder crt0.o; ps2sdk installs the real one.

source "$(dirname "$0")/../../lib/common.sh"

rm -f "$PS2DEV/ee/mips64r5900el-ps2-elf/lib/crt0.o"
