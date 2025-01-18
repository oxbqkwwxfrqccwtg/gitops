if test -z "$GITOPS_ENV_PATH"; then
    AC_MSG_ERROR([
        The environment variable 'GITOPS_ENV_PATH' is not set. This is a 
        programming error of the program, contact the program's maintainer.
    ])
fi

# AUTOCMD()
# --------------------------------------
AC_DEFUN([AUTOCMD], [
    cmd=$1
    AC_MSG_NOTICE([executing $cmd...])
    $cmd

    command_status=$?
    #TODO: there must be a better way to print the message just like a usual check
    if test $command_status -eq 0; then
      AC_MSG_RESULT([checking for ./configure exit code... 0 (success)])
    else

        AC_MSG_RESULT([checking for ./configure exit code... $command_status (failure)])

        if test $command_status -ne 123; then
            AC_MSG_NOTICE([executing automake --add-missing...])
            automake --add-missing

            AC_MSG_NOTICE([retrying $cmd...])

            $cmd

            command_status=$?
            #TODO: there must be a better way to print the message just like a usual check
            if test $command_status -eq 0; then
              AC_MSG_RESULT([checking for ./configure exit code... 0 (success)])
            else
              AC_MSG_RESULT([checking for ./configure exit code... 1 (failure)])
              MY_MSG_ERROR([panic: giving up...])
            fi
        else
            MY_MSG_ERROR([panic: giving up...])
        fi
    fi
])

AC_ARG_WITH([gitops-env],
            [AS_HELP_STRING([--with-gitops-env],
                            [keep GitOps data after configuration @<:@default=no@:>@])],
            [ARG_GITOPS_ENV='yes'],
            [ARG_GITOPS_ENV='no'])

AUTOCMD(["./configure"])

AC_MSG_CHECKING([for $GITOPS_ENV_PATH])
if test -f $GITOPS_ENV_PATH; then
    AC_MSG_RESULT([found])
    AC_MSG_NOTICE([sourcing properties from $GITOPS_ENV_PATH...])
    . ./$GITOPS_ENV_PATH
    AC_MSG_CHECKING([if configuration data should be kept...])
    if test "$ARG_GITOPS_ENV" '!=' 'yes'; then
        AC_MSG_RESULT([no])
        rm -v $GITOPS_ENV_PATH
    else
        AC_MSG_RESULT([yes])
    fi
else
    AC_MSG_RESULT([no])
    MY_MSG_ERROR([

        Bad news! If this error happened, there's probably something wrong with 
        how your configure.ac was patched.
    ])
fi

