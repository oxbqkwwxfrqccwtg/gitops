if test -z "$GITOPS_PATH"; then
    AC_MSG_ERROR([
        The environment variable 'GITOPS_PATH' is not set. This is a 
        programming error of the program, contact the program's maintainer.
    ])
fi

if test -z "$GITOPS_ENV_PATH"; then
    AC_MSG_ERROR([
        The environment variable 'GITOPS_ENV_PATH' is not set. This is a 
        programming error of the program, contact the program's maintainer.
    ])
fi

AC_ARG_WITH([autoconf],
            [AS_HELP_STRING([--with-autoconf],
                            [keep GitOps data after configuration @<:@default=no@:>@])],
            [ARG_AUTOCONF='yes'],
            [ARG_AUTOCONF='no'])

AC_MSG_CHECKING([for ./configure])
if ! test -x ./configure; then
    AC_MSG_RESULT([not found])
    ARG_AUTOCONF='yes'
fi

AC_MSG_CHECKING([if autoconf is required])
if test "$ARG_AUTOCONF" '=' 'yes'; then
    AC_MSG_RESULT([$ARG_AUTOCONF])

    # Check if configure.ac exists
    AC_MSG_CHECKING([for configure.ac])
    if test -f configure.ac; then
        AC_MSG_RESULT([found])

        AC_PATH_PROG([PROG_ACLOCAL], [aclocal])
        AC_PATH_PROG([PROG_AUTOCONF], [autoconf])

        AC_MSG_CHECKING([for configure.ac2])
        if test -f configure.ac2; then
            AC_MSG_RESULT([found])
            AC_MSG_ERROR([

                refusing to continue. There still is a backup of configure.ac.

                Move `configure.ac2`, to `configure.ac` to restore your state,
                or delete `configure.ac2` leave it as is.
            ])
        else
            AC_MSG_RESULT([not found])
        fi

        set -e
        AC_MSG_NOTICE([copying ./configure.ac to ./configure.ac2])
        cp configure.ac configure.ac2

        AC_MSG_NOTICE([patching ./configure.ac])
        echo '' >> configure.ac
        # make autoconf parser unaware of m4_include token
        echo "GITOPS_PATH='$GITOPS_PATH'" >> configure.ac
        echo "GITOPS_ENV_PATH='$GITOPS_ENV_PATH'" >> configure.ac
        cat $GITOPS_PATH/configure.ac-gitops-audit.m4 >> configure.ac

        AC_MSG_NOTICE([executing aclocal...])
        aclocal
        test $? -ne 0 && exit 1

        AC_MSG_NOTICE([executing autoconf...])
        autoconf
        test $? -ne 0 && exit 1

        if test "$with_exposed_patch_flag" '=' 'no'; then
            AC_MSG_NOTICE([moving ./configure.ac2 to ./configure.ac])
            mv -f configure.ac2 configure.ac
        fi
        set +e
    else
        AC_MSG_RESULT([not found])
        AC_MSG_ERROR([

            `configure.ac` is the primary input file for the `autoconf` shell 
            script generator. `autoconf` is used to configure build 
            environments and define environment checks. 

            https://www.gnu.org/software/autoconf/

            You can apply a generic framework to get started:

                `<gitops-path>/configure --with-framework=generic`

            See `<gitops-path>/configure --help`, for more information.
       ])
    fi
else
    AC_MSG_RESULT([no])
fi

