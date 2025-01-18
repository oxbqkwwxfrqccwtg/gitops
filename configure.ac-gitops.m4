# ==============================================================================
# Checking for Git submodules
# ==============================================================================
if test -z "$GITOPS_GIT_URL"; then
    AC_MSG_ERROR([
        The environment variable 'GITOPS_GIT_URL' is not set. This is a 
        programming error of the program, contact the program's maintainer.
    ])
fi

if test -z "$GITOPS_PROTO_PATH"; then
    AC_MSG_ERROR([
        The environment variable 'GITOPS_PROTO_PATH' is not set. This is a 
        programming error of the program, contact the program's maintainer.
    ])
fi

AC_ARG_WITH([gitops],
            [AS_HELP_STRING([--with-gitops],
                            [keep GitOps data after configuration @<:@default=no@:>@])],
            [ARG_GITOPS='yes'],
            [ARG_GITOPS='no'])


if test "$ARG_GITOPS" '=' 'yes'; then

    AC_MSG_CHECKING([for git repository])
    if test -f .git || test -d .git; then
        AC_MSG_RESULT([exists])
    else
        AC_MSG_RESULT([does not exist])
        AC_MSG_ERROR([

            Git repository is not initialized. GitOps is installed as a Git 
            submodule and thefore requires a Git repository context.
        ])
    fi

    AC_MSG_CHECKING([for .gitmodules])
    if test -f .gitmodules; then

        AC_MSG_RESULT([found])

        count=0
        for occurence in $(git submodule foreach --quiet "
            url=\$(git config remote.origin.url)
            if [[ \"\$url\" '=' '$GITOPS_GIT_URL' ]]; then
                echo \"\$path\"
            fi
        "); do
            count=$(expr $count '+' 1)
        done

        if test $count -gt 1; then
            AC_MSG_ERROR([
                $GITOPS_GIT_URL is a submodule of this repository more than once.
            ])
        elif test $count -eq 0; then
            AC_MSG_NOTICE([adding submodule...])
            GITOPS_PATH=$GITOPS_PROTO_PATH
            git submodule add $GITOPS_GIT_URL $GITOPS_PATH
            occurence=$GITOPS_PATH
        else
            if test -f $occurence/.git; then
                AC_MSG_NOTICE([setting 'GITOPS_PATH' to '$occurence'...])
                GITOPS_PATH=$occurence
                git submodule update --init
            fi
        fi
    else
        AC_MSG_NOTICE([adding submodule...])
        GITOPS_PATH=$GITOPS_PROTO_PATH
        git submodule add $GITOPS_GIT_URL $GITOPS_PATH
        occurence=$GITOPS_PATH
    fi
fi

#enqueuing environment checks to be picked up by the GitOps environment auditor
_IFS=$IFS; IFS=$'\n'
for property in $(cat "$GITOPS_PATH"/proto-env.txt); do
    test -z "$property" && continue
    GITOPS_ENV_CHECKS="$GITOPS_ENV_CHECKS\ngitops:proto-env:$property"
done
IFS=$_IFS; unset _IFS
