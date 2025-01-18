#!/usr/bin/env sh
set -e

if test -z "$GITOPS_PATH"; then
    echo "'GITOPS_PATH' required" >&2
    exit 1
fi

LIBDIR="$GITOPS_PATH/lib"
. "$LIBDIR/cicd.sh"
CICD_DIR="$GITOPS_PATH/srv/cicd"

help() {
    cat << EOF
Usage: $(basename "$0") NAME

Detect CI/CD environments

Options:

    -h              Display this help message

Arguments:

    NAME            name of CI/CD service

Explicit Errors:

    0 - ok
EOF
}

while getopts ":h" opt; do
    case $opt in
        h)
            help
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            help
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            help
            exit 2
            ;;
    esac
done
shift $((OPTIND -1))


cicd__detect "$CICD_DIR"
