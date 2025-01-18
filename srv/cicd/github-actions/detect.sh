#!/usr/bin/env sh
# detect if the current working directory satisfies the GitHub Actions
# service
if test -f "./.github/workflows/ci.yml"; then
    echo ".github/workflows/ci.yml"
    exit 0
else
    exit 1
fi
