#!/bin/bash
# Builds the macOS arm64 toolchain zip for a release tag on a Mac; --publish uploads it to that tag's GitHub release.
# Usage: scripts/release-macos.sh vYYYY.MM.DD [--publish]
set -e

if test "$(uname -s)" != "Darwin"; then
  echo "run this on macOS" >&2
  exit 1
fi

TAG="$1"
if test -z "$TAG"; then
  echo "usage: $0 <tag> [--publish]" >&2
  exit 2
fi
shift
PUBLISH=0
for arg in "$@"; do
  case "$arg" in
    --publish) PUBLISH=1 ;;
    *) echo "unknown argument: $arg" >&2; exit 2 ;;
  esac
done

for tool in brew git zip autoconf automake libtool bison flex makeinfo; do
  command -v "$tool" >/dev/null 2>&1 || { echo "missing tool: $tool (brew install autoconf automake libtool bison flex texinfo gmp mpfr libmpc zip)" >&2; exit 1; }
done

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${TAG#v}"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/ps2-toolchain-$VERSION.XXXXXX")"
trap 'git -C "$REPO_ROOT" worktree remove --force "$WORK/src" 2>/dev/null; rm -rf "$WORK"' EXIT

git -C "$REPO_ROOT" fetch --tags --quiet origin
git -C "$REPO_ROOT" worktree add --detach "$WORK/src" "refs/tags/$TAG"

# Homebrew's bison and flex are keg-only and newer than the system ones.
export PATH="$(brew --prefix bison)/bin:$(brew --prefix flex)/bin:$PATH"
export PS2DEV="$WORK/ps2dev"

(cd "$WORK/src/iop" && bash build.sh)
(cd "$WORK/src/ee" && bash build.sh)

mkdir -p "$WORK/staging/toolchain"
mv "$PS2DEV/ee" "$PS2DEV/iop" "$WORK/staging/toolchain/"
"$WORK/src/scripts/bundle-licenses.sh" "$WORK/src/build" "$WORK/staging/toolchain/LICENSES"
cp "$WORK/src/LICENSE" "$WORK/staging/toolchain/LICENSE"

OUT_DIR="$REPO_ROOT/build/release"
ZIP_PATH="$OUT_DIR/ps2-toolchain-$VERSION-darwin-arm64.zip"
mkdir -p "$OUT_DIR"
rm -f "$ZIP_PATH"
(cd "$WORK/staging" && zip -rq "$ZIP_PATH" toolchain)
echo "Built: $ZIP_PATH"

if test "$PUBLISH" -eq 1; then
  gh release upload "$TAG" "$ZIP_PATH" --clobber --repo ps2build/toolchain
fi
