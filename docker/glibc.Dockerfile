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
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV PS2DEV=/staging

WORKDIR /src
COPY lib lib
COPY scripts scripts
COPY LICENSE LICENSE

WORKDIR /src/iop
COPY iop .
RUN /bin/bash build.sh

WORKDIR /src/ee
COPY ee .
RUN /bin/bash build.sh

ARG VERSION
ENV VERSION=${VERSION}

RUN apt-get update && apt-get install -y zip && rm -rf /var/lib/apt/lists/*

COPY docker/package.sh /package.sh
CMD ["/package.sh"]
