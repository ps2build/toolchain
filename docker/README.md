# Docker builds

| Image | Produces |
|---|---|
| `glibc.Dockerfile` | Linux toolchain zip (`ps2-toolchain-<version>-linux-amd64.zip`) |
| `mingw.Dockerfile` | Windows toolchain zip (`ps2-toolchain-<version>-windows-amd64.zip`), cross-built from the Linux image's output |

## Linux

```bash
docker build -f docker/glibc.Dockerfile --build-arg VERSION=<version> -t ps2-toolchain-glibc .
docker run --rm -v "$(pwd)/build/release:/out" ps2-toolchain-glibc
```

The build runs during `docker build`; `docker run` bundles licenses and writes the zip to the mounted `/out`. `scripts/release-linux.sh` and `scripts/release-windows.sh` wrap the build and run commands. Both build `linux/amd64`, so on Apple silicon they run under emulation and are slow.

Host binaries are linked with `-static`, so the output does not depend on the image's distribution or libc version. `UBUNTU_VERSION` (default `24.04`) only selects the host tools used to build.

## Windows

`mingw.Dockerfile` builds binutils and GCC for `x86_64-w64-mingw32` as a Canadian cross. It reuses the Linux image's EE sysroot and uses its native compilers as build-time tools to compile libgcc.

## Output

`build/release/` (gitignored).
