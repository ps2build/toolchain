# toolchain

Builds the PlayStation 2 GCC toolchain for Linux, Windows and macOS: the EE (Emotion Engine) compiler with newlib and pthread support, and the IOP (I/O Processor) compiler. All binaries are statically linked.

## Build

```bash
scripts/release-linux.sh            # Linux zip in build/release/
scripts/release-linux.sh --publish  # also tag and create a GitHub release
```

macOS arm64 builds natively on a Mac with Homebrew (`brew install autoconf automake libtool bison flex texinfo gmp mpfr libmpc zip`):

```bash
scripts/release-macos.sh v2026.11.05            # build the tag, zip in build/release/
scripts/release-macos.sh v2026.11.05 --publish  # also upload to that tag's release
```

The Linux script requires Docker. The Windows toolchain is cross-built from Linux with `docker/mingw.Dockerfile`; see [docker/README.md](docker/README.md).

Each target builds on its own:

```bash
cd ee && ./build.sh      # all steps
cd ee && ./build.sh 3    # only step 3 (newlib)
```

`PS2DEV` is the install prefix. Sources are cloned into `build/<target>/`; a bad ref fails before any compilation starts.

## Layout

| Path | Contents |
|---|---|
| `ee/`, `iop/` | Per-target `config.sh` (source pins), `build.sh`, and ordered `steps/` |
| `lib/common.sh` | Source fetching, host environment, Canadian-cross helpers |
| `scripts/` | Release, license bundling and permission helpers |
| `docker/` | Linux and Windows build images |
| `.github/workflows/` | Build and release workflows |

## License

CC0 1.0 (see [LICENSE](LICENSE)). The toolchain components built here carry their own licenses, which are bundled into every release under `LICENSES/`.
