#!/usr/bin/env sh
if test -z "$GITOPS_TARGET_PATH"; then
    echo "'GITOPS_TARGET_PATH' not set."
    exit 1
fi

set -x
make -C "$GITOPS_TARGET_PATH" gitops-build

