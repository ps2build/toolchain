# syntax=docker/dockerfile:1
ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        texinfo \
        bison \
        flex \
        autoconf \
        automake \
        libtool \
        libgmp-dev \
        libmpfr-dev \
        libmpc-dev \
        zlib1g-dev \
        curl \
        ca-certificates \
        gcc-mingw-w64-x86-64 \
        g++-mingw-w64-x86-64 \
        mingw-w64-tools \
    && rm -rf /var/lib/apt/lists/*

ENV PS2DEV=/staging
ENV PS2_CROSS_HOST=x86_64-w64-mingw32

WORKDIR /src
COPY lib lib
COPY LICENSE LICENSE

WORKDIR /src/ee
COPY ee .

COPY --from=ps2-toolchain-glibc /staging/ee/mips64r5900el-ps2-elf /staging/ee/mips64r5900el-ps2-elf

ENV PS2_NATIVE_EE_TOOLS=/native-ee-tools
COPY --from=ps2-toolchain-glibc /staging/ee/bin /native-ee-tools/bin
COPY --from=ps2-toolchain-glibc /staging/ee/libexec /native-ee-tools/libexec
COPY --from=ps2-toolchain-glibc /staging/ee/lib /native-ee-tools/lib
COPY --from=ps2-toolchain-glibc /staging/ee/mips64r5900el-ps2-elf/bin /native-ee-tools/mips64r5900el-ps2-elf/bin

RUN /bin/bash build.sh 1
RUN /bin/bash build.sh 6

WORKDIR /src/iop
COPY iop .

ENV PS2_NATIVE_IOP_TOOLS=/native-iop-tools
COPY --from=ps2-toolchain-glibc /staging/iop/bin /native-iop-tools/bin
COPY --from=ps2-toolchain-glibc /staging/iop/libexec /native-iop-tools/libexec
COPY --from=ps2-toolchain-glibc /staging/iop/lib /native-iop-tools/lib
COPY --from=ps2-toolchain-glibc /staging/iop/mipsel-none-elf/bin /native-iop-tools/mipsel-none-elf/bin

RUN /bin/bash build.sh 1
RUN /bin/bash build.sh 2
