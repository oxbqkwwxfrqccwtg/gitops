#!/usr/bin/env sh
# detect if the current working directory satisfies the Gitlab CI/CD
# service
if test -f "./gitlab-ci.yml"; then
    echo "gitlab-ci.yml"
    exit 0
else
    exit 1
fi
