# Helpers shared by every target's steps. Sourced, never executed.

trap 'exit 1' ERR

PROC_NR=$(getconf _NPROCESSORS_ONLN)

# fetch_source <url> <ref> [ref-override]: clones or updates into ./<repo-name>, sets REPO_FOLDER.
fetch_source() {
  local repo_url="$1" repo_ref="$2" ref_override="$3"
  if test -n "$ref_override"; then
    repo_ref="$ref_override"
    printf 'Using requested ref %s\n' "$repo_ref"
  fi

  REPO_FOLDER="$(basename "$repo_url" .git)"

  if test ! -d "$REPO_FOLDER"; then
    git clone --depth 1 -b "$repo_ref" "$repo_url" "$REPO_FOLDER"
    return
  fi

  local have want
  have="$(git -C "$REPO_FOLDER" rev-parse HEAD 2>/dev/null)"
  # ^{} peels an annotated tag to its commit.
  want="$(git ls-remote "$repo_url" "$repo_ref" "$repo_ref^{}" 2>/dev/null | cut -f1 | tail -1)"

  if test -n "$have" && test "$have" = "$want"; then
    printf 'Already at %s (%s)\n' "$repo_ref" "$have"
    return
  fi

  git -C "$REPO_FOLDER" remote set-url origin "$repo_url"
  git -C "$REPO_FOLDER" fetch origin "$repo_ref" --depth=1
  git -C "$REPO_FOLDER" checkout -f FETCH_HEAD
}

# prepare_build_env: puts already-built target bin/ dirs on PATH, enables ccache, forces static host binaries on Linux.
prepare_build_env() {
  if test -n "$PS2DEV"; then
    export PATH="$PS2DEV/ee/bin:$PS2DEV/iop/bin:$PATH"
  fi

  if test -d /usr/local/ccache-links && command -v ccache >/dev/null 2>&1; then
    export PATH="/usr/local/ccache-links:$PATH"
  fi

  # macOS has no static libSystem/crt0.o, so -static fails every host-compiler link check (configure: "C compiler cannot create executables").
  if test "$(uname -s)" = "Linux"; then
    export LDFLAGS="-static ${LDFLAGS:-}"
    export LDFLAGS_FOR_BUILD="-static ${LDFLAGS_FOR_BUILD:-}"
  fi
}

check_dependencies() {
  local missing=0 tool
  for tool in git make gcc makeinfo; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      printf 'Missing required tool: %s\n' "$tool" >&2
      missing=1
    fi
  done
  if test "$missing" -ne 0; then
    printf 'Install the tool(s) above before continuing.\n' >&2
    exit 1
  fi
}

# _macos_stage_static_lib <staging-root> <lib-name> <package-prefix>: symlinks only <package-prefix>/lib/lib<lib-name>.a
# (never the .dylib sitting next to it) and the headers into <staging-root>/<lib-name>, so pointing --with-<lib-name>=
# there makes the linker statically embed it instead of picking up the Homebrew dylib at the brew-managed path.
_macos_stage_static_lib() {
  local root="$1" name="$2" prefix="$3" dest="$1/$2"
  rm -rf "$dest"
  mkdir -p "$dest/include" "$dest/lib"
  ln -s "$prefix"/include/*.h "$dest/include/"
  ln -s "$prefix/lib/lib$name.a" "$dest/lib/"
}

# macos_extra_configure_opts: sets TARG_XTRA_OPTS so configure statically links Homebrew/MacPorts gmp, mpfr and mpc
# (otherwise the host gcc/binutils binaries dynamically depend on those dylibs at their Homebrew path, unlike the
# fully static Linux host binaries).
macos_extra_configure_opts() {
  TARG_XTRA_OPTS=""
  if test "$(uname -s)" != "Darwin"; then
    return
  fi
  if command -v brew >/dev/null 2>&1; then
    local static_deps="${TMPDIR:-/tmp}/ps2-toolchain-static-deps"
    _macos_stage_static_lib "$static_deps" gmp "$(brew --prefix gmp)"
    _macos_stage_static_lib "$static_deps" mpfr "$(brew --prefix mpfr)"
    _macos_stage_static_lib "$static_deps" mpc "$(brew --prefix libmpc)"
    TARG_XTRA_OPTS="--with-system-zlib --with-gmp=$static_deps/gmp --with-mpfr=$static_deps/mpfr --with-mpc=$static_deps/mpc"
  elif command -v port >/dev/null 2>&1; then
    local macports_base
    macports_base="$(dirname "$(port -q contents gmp | grep gmp.h)" | sed 's#/include##')"
    TARG_XTRA_OPTS="--with-system-zlib --with-libiconv_prefix=$macports_base --with-gmp=$macports_base --with-mpfr=$macports_base --with-mpc=$macports_base"
  fi
}

# cross_configure_opts: sets CROSS_XTRA_OPTS for a Canadian cross when PS2_CROSS_HOST is set (e.g. x86_64-w64-mingw32).
cross_configure_opts() {
  CROSS_XTRA_OPTS=""
  if test -z "$PS2_CROSS_HOST"; then
    return
  fi
  local build_triple
  if test -x ./config.guess; then
    build_triple="$(./config.guess)"
  else
    build_triple="$(gcc -dumpmachine)"
  fi
  CROSS_XTRA_OPTS="--build=$build_triple --host=$PS2_CROSS_HOST"
}

# use_native_gcc <target> <native-tools-dir> <wrapper-dir>: in a Canadian cross the new compiler cannot run on the
# build machine, so libgcc is compiled with a native compiler. COMPILER_PATH is set only inside the wrapper so make
# and its other children do not inherit it.
use_native_gcc() {
  local target="$1" native_tools="$2" wrapper_dir="$3" tool
  CROSS_XTRA_OPTS="$CROSS_XTRA_OPTS --with-build-time-tools=$native_tools/bin"
  export PATH="$native_tools/bin:$PATH"

  rm -rf "$wrapper_dir"
  mkdir -p "$wrapper_dir"
  for tool in gcc g++; do
    cat > "$wrapper_dir/$target-$tool" <<WRAPPER
#!/bin/sh
export COMPILER_PATH="$native_tools/$target/bin"
exec "$native_tools/bin/$target-$tool" "\$@"
WRAPPER
    chmod +x "$wrapper_dir/$target-$tool"
  done
  export PATH="$wrapper_dir:$PATH"
}

# run_build <build-subdir> <url> <ref> [<url> <ref> ...] -- "$@"
# Fetches every source first so a bad ref fails before any compile, then runs steps/*.sh in order, or only the
# step numbers given in "$@".
run_build() {
  local build_subdir="$1"
  shift

  local urls=() refs=()
  while test "$1" != "--"; do
    if test "$#" -lt 2; then
      echo "run_build: malformed fetch list (missing -- terminator)" >&2
      exit 1
    fi
    urls+=("$1")
    refs+=("$2")
    shift 2
  done
  shift

  check_dependencies

  BUILD_ROOT="$TARGET_DIR/../build/$build_subdir"
  mkdir -p "$BUILD_ROOT"
  cd "$BUILD_ROOT"

  echo "=== Fetching all sources ==="
  local i
  for ((i = 0; i < ${#urls[@]}; i++)); do
    fetch_source "${urls[$i]}" "${refs[$i]}" ""
  done

  STEPS=($(ls "$TARGET_DIR/steps/"*.sh | sort))

  if test "$#" -gt 0; then
    for n in "$@"; do
      "${STEPS[$((n - 1))]}" || { echo "${STEPS[$((n - 1))]}: failed"; exit 1; }
    done
  else
    for step in "${STEPS[@]}"; do
      "$step" || { echo "$step: failed"; exit 1; }
    done
  fi
}
