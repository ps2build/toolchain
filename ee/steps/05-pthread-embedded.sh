#!/bin/bash
# EE pthread-embedded: pthreads over the PS2 kernel threads.

source "$(dirname "$0")/../../lib/common.sh"
source "$(dirname "$0")/../config.sh"

fetch_source "$PTHREAD_EMBEDDED_URL" "$PTHREAD_EMBEDDED_REF" "$1"
cd "$REPO_FOLDER"

prepare_build_env

cd platform/ps2
make --quiet -j "$PROC_NR" all
make --quiet -j "$PROC_NR" install
