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

Get a mapping of runtime environment variables and default values:w

Options:

    -h              Display this help message

Arguments:

    NAME            name of CI/CD service

Explicit Errors:

    0 - ok
    1 - invalid argument
    2 - missing argument
    3 - nothing supplied
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

case $1 in
    '')
        echo 'error: nothing supplied'
        help
        exit 3
        ;;
    *)
        cicd__is "$CICD_DIR/$1"
        ;;
esac


cicd__args "$CICD_DIR/$1"
