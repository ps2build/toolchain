#!/bin/sh
# Usage: restore-exec-bits.sh <toolchain-root>
# Artifact upload drops file modes; this restores them on the executable directories.
set -e

for p in ee/bin ee/libexec ee/mips64r5900el-ps2-elf/bin iop/bin iop/libexec iop/mipsel-none-elf/bin; do
    if [ -d "$1/$p" ]; then
        chmod -R +x "$1/$p"
    fi
done
