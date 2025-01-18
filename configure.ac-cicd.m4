
if test -z "$GITOPS_PATH"; then
    AC_MSG_ERROR([
        The environment variable 'GITOPS_PATH' is not set. This is a 
        programming error of the program, contact the program's maintainer.
    ])
fi

AC_ARG_WITH([cicd],
            [AS_HELP_STRING([--with-cicd],
                            [keep GitOps data after configuration @<:@default=no@:>@])],
            [ARG_CICD=$withval],
            [ARG_CICD='no'])

AC_MSG_CHECKING([CI/CD environment])
if test -z "$ARG_CICD"; then
    AC_MSG_RESULT([noto])
elif test "$ARG_CICD" '=' 'no'; then
    AC_MSG_RESULT([skipped])
else
    AC_MSG_RESULT([$ARG_CICD])
fi

if test "$ARG_CICD" '=' 'yes'; then
    AC_MSG_ERROR([argument_error
        `--with-cicd` requires a value, like `--with-cicd=foobar`
    ])
fi

if ! test "$ARG_CICD" '=' 'no'; then
    #bootstrap the workflow flag, should it not have been initialized, so
    #that we can suppress autoconf warnings for `--with-workflow` being unknown
    if test -z "$ARG_WORKFLOW"; then
        AC_ARG_WITH([workflow],
                    [AS_HELP_STRING([--with-workflow],
                                    [keep GitOps data after configuration @<:@default=no@:>@])],
                    [ARG_WORKFLOW=$withval])
    fi

    if test -z "$ARG_WORKFLOW"; then
        AC_MSG_ERROR([argument_error
            `--with-workflow=<workflow-type>` required
        ])
    fi

    AC_MSG_NOTICE([applying '$ARG_CICD' CI/CD for '$ARG_WORKFLOW' workflow...])
    GITOPS_PATH="$GITOPS_PATH" sh $GITOPS_PATH/libexec/cicd/apply.sh "$ARG_CICD" "$ARG_WORKFLOW"
    if test $? -ne 0; then
        AC_MSG_ERROR([runtime_error
            Oops. Applying CI/CD failed.
        ])
    fi

    #enqueuing environment checks to be picked up by the GitOps environment auditor
    _IFS=$IFS; IFS=$'\n'
    for arg in $(sh $GITOPS_PATH/libexec/cicd/args.sh "$CI_ENV"); do
        GITOPS_ENV_CHECKS="$GITOPS_ENV_CHECKS\ncicd:$name:$arg"
    done
    IFS=$_IFS; unset _IFS
fi
