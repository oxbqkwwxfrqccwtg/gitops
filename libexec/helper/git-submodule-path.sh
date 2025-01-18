#!/usr/bin/env sh

help() {
    cat << EOF
Usage: $(basename "$0") URL

Get the path of a Git submodule by URL

Options:

    -h              Display this help message

Arguments:

    URL - URL of registered submodule

Explicit Errors:

    10 - no URL provided
    11 - URL is assigned to multiple submodules
    12 - no match
    13 - no .gitmodules file exists
EOF
}

URL=$1

if test -z "$URL"; then
    echo "error: no url provided" >&2
    help
    exit 10
fi

if test -f .gitmodules; then
    count=0
    for occurence in $(git submodule foreach --quiet "
        url=\$(git config remote.origin.url)
        if test \"\$url\" '=' '$URL'; then
            echo \"\$path\"
        fi
    "); do
        count=$(expr $count '+' 1)
    done
    #checking for submodule path
    if test $count -gt 1; then
        echo "$URL is a submodule of this repository more than once." >&2
        exit 11
    elif test $count -le 0; then
        echo "no match" >&2
        exit 12
    fi

    echo "$occurence"
    exit 0
else
    echo "error: no .gitmodules" >&2
    exit 13
fi
