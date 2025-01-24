test -z "$GITOPS_PATH" && {
    AC_MSG_ERROR([
        The environment variable 'GITOPS_PATH' is not set. This is a 
        programming error of the program, contact the program's maintainer.
    ])
}

test -z "$GITOPS_ENV_PATH" && {
    AC_MSG_ERROR([
        The environment variable 'GITOPS_ENV_PATH' is not set. This is a 
        programming error of the program, contact the program's maintainer.
    ])
}

m4_defin([_GITOPS_PATH])

AC_ARG_WITH(
    [autoconf],
    [AS_HELP_STRING(
        [--with-autoconf],
        [initialize '$C_PATH' @<:@default=no@:>@]
    )],
    [ARG_AUTOCONF='yes'],
    [ARG_AUTOCONF='no']
)

m4_define([_M4_C_PATH], [./configure])
m4_define([_M4_AC_PATH], [./configure.ac])
m4_define([_M4_AC_BACKUP_PATH], [./configure.last.ac])
m4_pattern_allow(^GITOPS_)

AC_MSG_CHECKING([for 'C_PATH'])

test -x m4_quote(_M4_C_PATH)

case $? in
    0)
        AC_MSG_RESULT([found])
        ;;
    1)
        AC_MSG_RESULT([not found])

        ARG_AUTOCONF='yes'
        ;;
esac

AC_MSG_CHECKING([--with-autoconf option])

test "$ARG_AUTOCONF" '=' 'yes'

case $? in 
    0)
        AC_MSG_RESULT([$ARG_AUTOCONF])

        AC_PATH_PROG([PROG_ACLOCAL], [aclocal])
        AC_PATH_PROG([PROG_AUTOCONF], [autoconf])

        AC_MSG_CHECKING([for '_MYM4_AC_PATH'])

        test -f _M4_AC_PATH

        case $? in
            0)
                AC_MSG_RESULT([found])
                ;;
            1)
                AC_MSG_RESULT([not found])

                AC_MSG_ERROR([

                     `_MYM4_AC_PATH` is the primary input file for the `autoconf` shell 
                     script generator. `autoconf` is used to configure build 
                     environments and define environment checks. 

                     https://www.gnu.org/software/autoconf/

                     You can apply a generic framework to get started:

                         `<gitops-path>/configure --with-framework=generic`

                     See `<gitops-path>/configure --help`, for more information.
                ])
                ;;
        esac

        AC_MSG_CHECKING([for '_MYM4_AC_BACKUP_PATH'])

        test -f _MYM4_AC_BACKUP_PATH

        case $? in
            1)
                AC_MSG_RESULT([not found])
                ;;
            0)
                AC_MSG_RESULT([found])

                AC_MSG_ERROR([

                    refusing to continue. There still is a backup of configure.ac.

                    Move `_MYM4_AC_BACKUP_PATH`, to `configure.ac` to restore your state,
                    or delete `_MYM4_AC_BACKUP_PATH` to continue.
                ])
                ;;
        esac

        AC_MSG_NOTICE([copying '_MYM4_AC_PATH' to '_MYM4_AC_BACKUP_PATH'...])

        set -e

        cp _MYM4_AC_PATH _MYM4_AC_BACKUP_PATH

        AC_MSG_NOTICE([patching '_MYM4_AC_PATH' with core environment and auditor...])

        echo '' >> _MYM4_AC_PATH
        echo "GITOPS_PATH='$GITOPS_PATH'" >> _MYM4_AC_PATH
        echo "GITOPS_ENV_PATH='$GITOPS_ENV_PATH'" >> _MYM4_AC_PATH
        cat "$GITOPS_PATH"/configure.ac-gitops-audit.m4 >> _MYM4_AC_PATH

        AC_MSG_NOTICE([executing aclocal...])

        aclocal

        test $? -ne 0 && exit 1

        AC_MSG_NOTICE([executing autoconf...])

        autoconf

        test $? -ne 0 && exit 1

        set +e
        ;;
    1)
        AC_MSG_RESULT([no])
        ;;
esac
