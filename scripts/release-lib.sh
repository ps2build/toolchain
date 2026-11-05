#!/bin/bash
# Shared by the release-*.sh scripts: parses "<tag> [--publish]", checks the tag out into a temporary worktree, and uploads the zip.

release_init() {
  TAG=""
  PUBLISH=0
  for arg in "$@"; do
    case "$arg" in
      --publish) PUBLISH=1 ;;
      -*) echo "unknown argument: $arg" >&2; exit 2 ;;
      *) TAG="$arg" ;;
    esac
  done
  if test -z "$TAG"; then
    echo "usage: $0 <tag> [--publish]" >&2
    exit 2
  fi

  REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd)"
  VERSION="${TAG#v}"
  OUT_DIR="$REPO_ROOT/build/release"
  WORK="$(mktemp -d "${TMPDIR:-/tmp}/ps2-toolchain-$VERSION.XXXXXX")"
  SRC="$WORK/src"
  trap 'git -C "$REPO_ROOT" worktree remove --force "$SRC" 2>/dev/null; rm -rf "$WORK"' EXIT

  git -C "$REPO_ROOT" fetch --tags --quiet origin
  git -C "$REPO_ROOT" worktree add --detach "$SRC" "refs/tags/$TAG"
  mkdir -p "$OUT_DIR"
}

release_publish() {
  local zip="$1"
  echo "Built: $zip"
  if test "$PUBLISH" -eq 1; then
    gh release view "$TAG" --repo ps2build/toolchain >/dev/null 2>&1 \
      || gh release create "$TAG" --title "$TAG" --notes "" --verify-tag --repo ps2build/toolchain
    gh release upload "$TAG" "$zip" --clobber --repo ps2build/toolchain
  fi
}
