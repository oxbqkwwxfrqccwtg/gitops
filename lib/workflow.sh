#!/usr/bin/env sh
test -z "$LIBDIR" && { echo "error: 'LIBDIR' not set" >&2; exit 1; }
. "$LIBDIR"/cicd.sh

workflow__list() {
    if test -z "$1"; then
        echo "error: missing argument 1: path" >&2
        return 1
    fi

    path="$1"

    printf "$(cicd__workflows "$path")" | sort | uniq
}

workflow__detect() {
    if test -z "$1"; then
        echo "error: missing argument 1: path" >&2
        return 1
    fi

    path="$1"
    echo "error: not implemented" >&2
    return 121
}

