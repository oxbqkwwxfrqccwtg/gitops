#!/usr/bin/env sh
# detect if the current working directory satisfies the Jenkins
# service
if test -f "./Jenkinsfile"; then
    echo "Jenkinsfile"
    exit 0
else
    exit 1
fi
