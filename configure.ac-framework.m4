if test -z "$GITOPS_PATH"; then
    AC_MSG_ERROR([
        The environment variable 'GITOPS_PATH' is not set. This is a 
        programming error of the program, contact the program's maintainer.
    ])
fi

AC_ARG_WITH([framework],
            [AS_HELP_STRING([--with-framework],
                            [keep GitOps data after configuration @<:@default=no@:>@])],
            [ARG_FRAMEWORK=$withval],
            [ARG_FRAMEWORK='no'])

AC_MSG_CHECKING([for framework initialization])
if test "$ARG_FRAMEWORK" '=' 'no'; then
    AC_MSG_RESULT([not requested])
elif test "$ARG_FRAMEWORK" '=' 'yes'; then
    AC_MSG_RESULT([requested, but insufficient])

    GITOPS_PATH=$GITOPS_PATH sh $GITOPS_PATH/libexec/framework/apply.sh -h
else
    AC_MSG_RESULT([requested])

    AC_MSG_NOTICE([appyling '$ARG_FRAMEWORK' framework...])
    GITOPS_PATH="$GITOPS_PATH" sh $GITOPS_PATH/libexec/framework/apply.sh "$ARG_FRAMEWORK"
    if test $? -ne 0; then
        MY_MSG_ERROR([appyling framework failed...])
    fi
    GITOPS_PATH="$GITOPS_PATH" sh $GITOPS_PATH/libexec/framework/init.sh "$ARG_FRAMEWORK"
    if test $? -ne 0; then
        MY_MSG_ERROR([initializing framework failed...])
    fi
fi
