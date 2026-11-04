#!/bin/bash
# Builds the Linux toolchain zip in Docker; --publish also tags and creates a GitHub release.
set -e

# Stop Git Bash from rewriting container paths.
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL="*"

if pwd -W >/dev/null 2>&1; then
  REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd -W)"
else
  REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi
VERSION="${VERSION:-$(date +%Y.%m.%d)}"
OUT_DIR="$REPO_ROOT/build/release"
ZIP_PATH="$OUT_DIR/ps2-toolchain-$VERSION-linux-amd64.zip"

PUBLISH=0
for arg in "$@"; do
  case "$arg" in
    --publish) PUBLISH=1 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

docker build -f "$REPO_ROOT/docker/glibc.Dockerfile" --build-arg "VERSION=$VERSION" -t ps2-toolchain-glibc "$REPO_ROOT"

mkdir -p "$OUT_DIR"
rm -f "$ZIP_PATH"
docker run --rm -v "$OUT_DIR:/out" ps2-toolchain-glibc

if test ! -f "$ZIP_PATH"; then
  echo "expected $ZIP_PATH after the container run" >&2
  exit 1
fi
echo "Built: $ZIP_PATH"

if test "$PUBLISH" -eq 1; then
  git -C "$REPO_ROOT" tag "v$VERSION" 2>/dev/null || true
  git -C "$REPO_ROOT" push origin "v$VERSION"
  gh release create "v$VERSION" "$ZIP_PATH" --title "v$VERSION" --repo ps2build/toolchain
fi
