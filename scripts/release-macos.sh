#!/bin/bash
# Builds ps2-toolchain-<version>-darwin-arm64.zip for a tag on a Mac; --publish uploads it to the tag's release.
# Usage: scripts/release-macos.sh vYYYY.MM.DD [--publish]
set -e

if test "$(uname -s)" != "Darwin"; then
  echo "run this on macOS" >&2
  exit 1
fi
for tool in brew git zip autoconf automake libtool bison flex makeinfo; do
  command -v "$tool" >/dev/null 2>&1 || { echo "missing tool: $tool (brew install autoconf automake libtool bison flex texinfo gmp mpfr libmpc zip)" >&2; exit 1; }
done

source "$(dirname "$0")/release-lib.sh"
release_init "$@"

export PATH="$(brew --prefix bison)/bin:$(brew --prefix flex)/bin:$PATH"
export PS2DEV="$WORK/ps2dev"

(cd "$SRC/iop" && bash build.sh)
(cd "$SRC/ee" && bash build.sh)

mkdir -p "$WORK/staging/toolchain"
mv "$PS2DEV/ee" "$PS2DEV/iop" "$WORK/staging/toolchain/"
"$SRC/scripts/bundle-licenses.sh" "$SRC/build" "$WORK/staging/toolchain/LICENSES"
cp "$SRC/LICENSE" "$WORK/staging/toolchain/LICENSE"

ZIP="$OUT_DIR/ps2-toolchain-$VERSION-darwin-arm64.zip"
rm -f "$ZIP"
(cd "$WORK/staging" && zip -rq "$ZIP" toolchain)

release_publish "$ZIP"
