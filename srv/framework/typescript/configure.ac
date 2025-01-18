AC_INIT([Your Project Name], [1.0])
AC_PREREQ([2.69])

# =======================================================================
# Checking for required programs
#
# npm includes binary version checking through npm package.json `engines`
# =======================================================================
REQUIRED_PROGRAMS="node npm"
for prog in $REQUIRED_PROGRAMS; do
    AC_CHECK_PROGS([_PROG], [$prog], [no])
    if test "$_PROG" = "no"; then
        AC_MSG_ERROR([$prog is required but not found])
    fi

    unset _PROG
    # flush cache, because we're reusing the same variable name
    # see 5.2.2 in https://www.gnu.org/software/autoconf/manual/autoconf-2.68/html_node/Generic-Programs.html,
    # for more information.
    unset ac_cv_prog__PROG
done


# =======================================================================
# Initializing npm
# =======================================================================
AC_MSG_NOTICE(["initializing npm..."])
npm install

GITOPS_DOC="/build/doc/*"
GITOPS_BUILD="/build/production/*"
GITOPS_TEST="null"
GITOPS_AUDIT="null"
GITOPS_RELEASE="null"
GITOPS_VERSION="0.1"
GITOPS_WORKFLOW="gitflow"

AC_OUTPUT
