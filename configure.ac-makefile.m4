if test -z "$GITOPS_PATH"; then
    AC_MSG_ERROR([
        The environment variable 'GITOPS_PATH' is not set. This is a 
        programming error of the program, contact the program's maintainer.
    ])
fi

for target in $(cat "$GITOPS_PATH"/make-targets.txt); do
    name=$(echo "$target" | cut -d ':' -f 1)
    flag=$(echo "$target:" | cut -d ':' -f 2)

    AC_MSG_CHECKING([for phony Makefile target '$name:'])
    M_TARGET=$(sh $GITOPS_PATH/libexec/makefile/check-targets.sh "$name")
    if test $? -eq 0; then
        AC_MSG_RESULT([found])
    elif test "$flag" '=' 'optional'; then
        AC_MSG_RESULT([not found, but not required])
    else
        AC_MSG_RESULT([not found])
        MY_MSG_ERROR([

            The Makefile target `$name:` is not defined, or the Makefile does not
            exist. Either way, make sure to create them before you continue.

            If you updated your `Makefile.am`, run `./configure --with-automake`.
            Alternatively, you can write directly to `Makefile`, however this 
            is not recommended
        ])
    fi
done

