#!/bin/sh
set -e

help() {
    cat <<- EOF
    Check if a Makefile and specific targets are defined

    Usage: $0 [OPTIONS] [TARGET] [...}

    Options:
        -h    Display this help message

    Positional arguments:
        TARGET          name of target to check
EOF
}

if test -z "$GITOPS_PATH"; then
    echo "'GITOPS_PATH' required" >&2
    exit 1
fi

LIBDIR="$GITOPS_PATH/lib"
. "$LIBDIR/makefile.sh"

# Check for the -h flag
if [ "$1" '=' '-h' ]; then
  help
  exit 0
fi

# If no targets are provided, show help
if [ "$#" -eq 0 ]; then
  help
  exit 1
fi

if [ ! -f 'Makefile' ]; then
    echo "error: 'Makefile' not found" 1>&2
    return 1
fi

# Call the check_targets function with the provided arguments
makefile__check_targets "$@"
