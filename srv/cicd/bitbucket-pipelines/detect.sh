#!/usr/bin/env sh
# detect if the current working directory satisfies the Bitbucket Pipelines
# service
if test -f "./bitbucket-pipelines.yml"; then
    echo "bitbucket-pipelines.yml"
    exit 0
else
    exit 1
fi
