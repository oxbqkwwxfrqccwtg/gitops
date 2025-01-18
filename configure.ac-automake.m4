AC_ARG_WITH([automake],
            [AS_HELP_STRING([--with-automake],
                            [keep GitOps data after configuration @<:@default=no@:>@])],
            [ARG_AUTOMAKE='yes'],
            [ARG_AUTOMAKE='no'])

AC_MSG_CHECKING([for ./Makefile])
if ! test -f ./Makefile; then
    AC_MSG_RESULT([not found])
    ARG_AUTOMAKE='yes'
else
    AC_MSG_RESULT([found])
fi

AC_MSG_CHECKING([if automake is required])
if test "$ARG_AUTOMAKE" '=' 'yes'; then
    AC_MSG_RESULT([$ARG_AUTOCONF])

    # Check if Makefile.am exists
    AC_MSG_CHECKING([for ./Makefile.am])
    if test -f 'Makefile.am'; then
        AC_MSG_RESULT([found])
    else
        AC_MSG_RESULT([not found])
        MY_MSG_ERROR([

            `Makefile.am` does not exist, but is required.
        ])
    fi

    AC_MSG_CHECKING([for ./Makefile.in])
    if ! test -f 'Makefile.in'; then
        AC_MSG_RESULT([not found])
        AC_MSG_NOTICE([executing automake...])
        set -e
        automake --add-missing
        set +e
    else
        AC_MSG_RESULT([found])
    fi
else
    AC_MSG_RESULT([no])
fi

