#!/usr/bin/env sh
if test -z "$GITOPS_PATH"; then
    echo "'GITOPS_PATH' not set."
    exit 1
fi

if test -z "$GITOPS_TARGET_PATH"; then
    echo "'GITOPS_TARGET_PATH' not set."
    exit 1
fi


collect() {
    name=$1; shift
    patterns=$@

    echo "=== $name ==="

    if ! test -z "$patterns" && ! test "$patterns" '=' 'null'; then
        set -f
        sh $GITOPS_PATH/libexec/file/check.sh -s "$GITOPS_TARGET_PATH" $patterns
        if test $? -ne 0; then
            echo "error: incomplete '$name' target output" >&2
            return 1
        fi
        set +f
    else
        echo "warning: '$name' target is not expecting output" >&2
    fi
}

working_dir="$(pwd)"
cd "$GITOPS_TARGET_PATH"
semver_string="$GITOPS_PATH/sbin/git-semver-helper"
if test $? -ne 0; then
    echo "refusing to release unknown, or development version '$semver_string'" >&2
    exit 1
fi

set -f
collect doc $GITOPS_DOC
error=$(expr $error '+' $?)
collect build $GITOPS_BUILD
error=$(expr $error '+' $?)
collect test $GITOPS_TEST
error=$(expr $error '+' $?)
collect audit $GITOPS_AUDIT
error=$(expr $error '+' $?)
set +f

if test "$error" -ne 0; then
    exit 1
fi

make -C "$GITOPS_TARGET_PATH" gitops-release
