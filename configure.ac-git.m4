if test -z "$GITOPS_GIT_URL"; then
    AC_MSG_ERROR([
        The environment variable 'GITOPS_GIT_URL' is not set. This is a 
        programming error of the program, contact the program's maintainer.
    ])
fi

AC_ARG_WITH([git],
            [AS_HELP_STRING([--with-git],
                            [keep GitOps data after configuration @<:@default=no@:>@])],
            [ARG_GIT='yes'],
            [ARG_GIT='no'])

AC_PATH_PROG([PROG_GIT], [git])

AC_MSG_CHECKING([for .git directory or file])
if test -d .git || test -f .git; then
    AC_MSG_RESULT([found])
else
    AC_MSG_RESULT([not found])

    AC_MSG_CHECKING([if initializing git])
    if test "$ARG_GIT" '=' 'yes'; then
        AC_MSG_RESULT([requested])

        AC_MSG_NOTICE([initializing git repository...])

        set -e 
        git init 2>/dev/null
        git submodule update --remote --recursive
        set +e
    else
        AC_MSG_RESULT([not requested])
    fi
fi

AC_MSG_CHECKING([for git config remote.origin.url])
GIT_REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null)
if test "$GIT_REMOTE_URL" = "$GITOPS_GIT_URL"; then
  AC_MSG_ERROR([

    The remote.origin.url is set to '$GITOPS_GIT_URL' 
    which is not allowed and probably means that your working directory is set 
    to the root of the GitOps './configure' script. `cd` into the root of your
    Git repository instead.
])
else
  AC_MSG_RESULT([allowed])
fi
