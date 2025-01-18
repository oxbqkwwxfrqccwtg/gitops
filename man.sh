#!/usr/bin/env sh
GITOPS_PATH="$(dirname "$(realpath $0)")"

if test -z "$1"; then
    echo "error: missing argument: command" >&2
    exit 1
fi

while getopts ":h" opt; do
  case $opt in
    h) $GITOPS_PATH/man man; exit 1;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
  esac
done

shift $(expr $OPTIND '-' 1)

command -v man
if test $? -eq 0; then
    man -l "$GITOPS_PATH/$1.1"
else
    cat "$GITOPS_PATH/$1.help" | more
fi

