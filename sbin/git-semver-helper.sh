#!/usr/bin/env sh
NAME="$(basename $0 | sed 's|\.sh$||')"
GITOPS_PATH="$(dirname "$(realpath "$0")")"

. "$GITOPS_PATH"/lib/semver.sh

notify() {
    echo "$NAME: $@"
}

panic() {
    exit_code=$1; shift
    notify "error: $@"
    exit $exit_code
}

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "error: not a git repository."
    exit 1
fi

#git fetch --tags >/dev/null 2>&1
latest_semver_tag=$(git tag --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+.*$' | head -n 1)

test -z "$latest_semver_tag" && \
    panic 1 "git repository under '$(pwd)' has no semver formatted tag, run \`git tag v1.0.0\` to add one."

if git diff-index --quiet HEAD -- && test -z "$(git ls-files --others --exclude-standard)"; then
    semver__parse "$latest_semver_tag" 1>/dev/null
    echo $latest_semver_tag
else
    semver_string=$(semver__upgrade dev "$latest_semver_tag")
    echo $semver_string
fi
