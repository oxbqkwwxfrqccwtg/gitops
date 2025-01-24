test -z "$GITOPS_GIT_URL" && {
    AC_MSG_ERROR([
        The environment variable 'GITOPS_GIT_URL' is not set. This is a 
        programming error of the program, contact the program's maintainer.
    ])
}

AC_ARG_WITH(
    [git],
    [AS_HELP_STRING(
        [--with-git],
        [initialize Git repository @<:@default=no@:>@]
    )],
    [ARG_GIT='yes'],
    [ARG_GIT='no']
)

AC_PATH_PROG([PROG_GIT], [git])

AC_MSG_CHECKING([for .git directory or file])

test -d .git || test -f .git

case $? in
    1)
        AC_MSG_RESULT([not found])
        ;;
    0)
        AC_MSG_RESULT([found])

        pwd_is_git_repo='yes'
        ;;
esac

test "$pwd_is_git_repo" '=' 'yes' && {
    pwd_is_git_repo=

    AC_MSG_CHECKING([if initializing git])

    test "$ARG_GIT" '=' 'yes'

    case $? in
        1)
            AC_MSG_RESULT([not requested])
            ;;
        0)
            AC_MSG_RESULT([requested])

            init_git_repo='yes'

            AC_MSG_NOTICE([initializing git repository...])

            set -e 

            git init 2>/dev/null

            AC_MSG_NOTICE([updating git submodules...])

            git submodule update --remote --recursive

            set +e
            ;;
    esac
}

AC_MSG_CHECKING([for git config remote.origin.url])

GIT_REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null)

test "$GIT_REMOTE_URL" '=' "$GITOPS_GIT_URL"

case $? in
    0)
        AC_MSG_ERROR([

            The remote.origin.url is set to '$GITOPS_GIT_URL' 
            which is not allowed and probably means that your working directory is set 
            to the root of the GitOps './configure' script. `cd` into the root of your
            Git repository instead.
        ])
        ;;
    1)
        AC_MSG_RESULT([allowed])
        ;;
esac
