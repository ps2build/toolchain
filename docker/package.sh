#!/bin/sh
# Image CMD: bundles licenses and zips the toolchain into /out.
set -e

mkdir -p /staging/toolchain
mv /staging/ee /staging/iop /staging/toolchain/

/src/scripts/bundle-licenses.sh /src/build /staging/toolchain/LICENSES
cp /src/LICENSE /staging/toolchain/LICENSE

cd /staging
zip -r "/out/ps2-toolchain-${VERSION}-linux-amd64.zip" toolchain
