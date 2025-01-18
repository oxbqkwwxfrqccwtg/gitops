#!/usr/bin/env sh
set -e

if test -z "$GITOPS_PATH"; then
    echo "'GITOPS_PATH' required" >&2
    exit 1
fi

LIBDIR="$GITOPS_PATH/lib"
. "$LIBDIR/cicd.sh"
PIPELINE_DIR="$GITOPS_PATH/srv/cicd"
SERVICES=$(cicd__list $PIPELINE_DIR)

help() {
    cat << EOF
Usage: $(basename "$0") NAME

Apply a CI/CD pipeline to the working directory

Options:

    -h              Display this help message

Arguments:

    NAME            name of CI/CD service

$(echo "$(echo $SERVICES | xargs -I % sh -c 'echo "$(basename %) - $(cat %/README.txt | head -n 1) \n\n"')" | fold -w 56 | sed 's/^/                        /')

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
        cicd__is "$CICD_DIR/$1"
        ;;
esac


cicd__apply "$CICD_DIR/$1"
