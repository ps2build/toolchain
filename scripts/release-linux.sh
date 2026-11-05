#!/bin/bash
# Builds ps2-toolchain-<version>-linux-amd64.zip for a tag in Docker; --publish uploads it to the tag's release.
# Usage: scripts/release-linux.sh vYYYY.MM.DD [--publish]
set -e
source "$(dirname "$0")/release-lib.sh"
release_init "$@"

docker build --platform linux/amd64 -f "$SRC/docker/glibc.Dockerfile" --build-arg "VERSION=$VERSION" -t ps2-toolchain-glibc "$SRC"

ZIP="$OUT_DIR/ps2-toolchain-$VERSION-linux-amd64.zip"
rm -f "$ZIP"
docker run --rm --platform linux/amd64 -v "$OUT_DIR:/out" ps2-toolchain-glibc
test -f "$ZIP" || { echo "expected $ZIP after the container run" >&2; exit 1; }

release_publish "$ZIP"
