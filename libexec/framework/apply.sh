#!/usr/bin/env sh
set -e

if test -z "$GITOPS_PATH"; then
    echo "'GITOPS_PATH' required" >&2
    exit 1
fi

LIBDIR="$GITOPS_PATH/lib"
. "$LIBDIR/framework.sh"
FRAMEWORK_DIR="$GITOPS_PATH/srv/framework"
FRAMEWORKS=$(framework__list $FRAMEWORK_DIR)

help() {
    cat << EOF
Usage: $(basename "$0") NAME

Apply a framework to the working directory

Options:

    -h              Display this help message

Arguments:

    NAME            name of framework

$(echo "$(echo $FRAMEWORKS | xargs -I % sh -c 'echo "$(basename %) - $(cat %/README.txt | head -n 1) \n\n"')" | fold -w 56 | sed 's/^/                        /')

Explicit Errors:

    5  - invalid command-line argument
    6  - missing required command-line argument
    10 - no distribution supplied
    11 - unknown distribution
    12 - configure.ac framework does not exist
    13 - Makefile.am framework does not exist
EOF
}

while getopts ":s:t:h" opt; do
    case $opt in
        s)
            base_path=$OPTARG
            ;;
        t)
            target_base_path=$OPTARG
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

case $1 in
    '')
        echo 'error: nothing supplied'
        help
        exit 10
        ;;
    *)
        framework__is "$FRAMEWORK_DIR/$1"
        ;;
esac


framework__apply "$FRAMEWORK_DIR/$1"
