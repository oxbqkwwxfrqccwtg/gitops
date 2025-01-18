#!/usr/bin/env sh
set +e

SCRIPT_BASENAME="$(basename $0)"

export GITOPS_TARGET_PATH="$(pwd)"
GITOPS_PATH="$(realpath $(dirname $0))"
GITOPS_ENV_PATH='./gitops.env'


while getopts ":h" opt; do
  case $opt in
    h) $GITOPS_PATH/man make; exit 1;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
  esac
done

shift $(expr $OPTIND '-' 1)

PREFIX='agent'
! test -z "$@" && PREFIX="$PREFIX-"

if ! test -f $GITOPS_ENV_PATH; then
    echo "$SCRIPT_BASENAME: error: '$GITOPS_ENV_PATH' missing, configuring..." >&2

    "$GITOPS_PATH/configure" --with-gitops-env --with-autoconf \
        --without-porcelain-git #TODO: remove me

    if test $? -ne 0; then
        echo "$SCRIPT_BASENAME: error: autoconfiguration failed." >&2
        exit 1
    fi
fi

. "$GITOPS_ENV_PATH"

make -C "$GITOPS_PATH" $PREFIX$@
exit_code=$?
exit $exit_code
