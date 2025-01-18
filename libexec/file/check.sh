#!/usr/bin/env sh
set -e

if test -z "$GITOPS_PATH"; then
    echo "'GITOPS_PATH' required" >&2
    exit 1
fi

LIBDIR="$GITOPS_PATH/lib"
. "$LIBDIR/file.sh"

help() {
    cat << EOF
Usage: $(basename "$0") [OPTION] PATTERN [...]

Match a list of globbing patterns against a directory

Options:

    -h              Display this help message
    -s BASEDIR      Base directory [required]

Arguments:

    BASEDIR         Directory to check
    PATTERN         Pattern that must match
EOF
}

while getopts ":s:h" opt; do
    case $opt in
        s)
            base_path=$OPTARG
            ;;
        h)
            help
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            help
            exit 5
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            help
            exit 6
            ;;
    esac
done
shift $((OPTIND -1))

set -f
file__gglobs "$base_path" $@
exit $?
