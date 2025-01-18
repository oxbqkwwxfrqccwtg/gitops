#!/usr/bin/env sh
set -x
AGENTDIR=$(realpath $(dirname $0))
make gitops-test

