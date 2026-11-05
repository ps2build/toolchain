#!/bin/bash
# Builds ps2-toolchain-<version>-windows-amd64.zip for a tag, cross-compiled in Docker; --publish uploads it to the tag's release.
# Usage: scripts/release-windows.sh vYYYY.MM.DD [--publish]
set -e
source "$(dirname "$0")/release-lib.sh"
release_init "$@"

docker build --platform linux/amd64 -f "$SRC/docker/glibc.Dockerfile" --build-arg "VERSION=$VERSION" -t ps2-toolchain-glibc "$SRC"
docker build --platform linux/amd64 -f "$SRC/docker/mingw.Dockerfile" --build-arg "VERSION=$VERSION" -t ps2-toolchain-mingw "$SRC"

ZIP="$OUT_DIR/ps2-toolchain-$VERSION-windows-amd64.zip"
rm -f "$ZIP"
docker run --rm --platform linux/amd64 -v "$OUT_DIR:/out" ps2-toolchain-mingw
test -f "$ZIP" || { echo "expected $ZIP after the container run" >&2; exit 1; }

release_publish "$ZIP"
