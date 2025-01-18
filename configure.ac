# configure.ac
# ===============================
# Project: GitOps
# Purpose: Configuration script for building the project
# Author: Your Name
# ===============================

AC_PREREQ([2.69])
AC_INIT([administratrix GitOps], [1.0], [gitops@administratrix.de])

echo $0
if test "$(basename $0)" '=' 'configure'; then
    GITOPS_PATH="$(realpath $(dirname $0))"
fi

# The git origin associated with this GitOps distribution.
GITOPS_GIT_URL='git@bitbucket.org:administratrix/gitops.git'
# The local path to the base directory of GitOps distribution
# The local path to the base directory of the GitOps distribution, should it 
# not be git submodule
GITOPS_PROTO_PATH='.gitops'

#needs to be exported, because not defined in client configure.ac
export GITOPS_ENV_PATH="gitops.env"

# List of auxiliary files to check
AUTOMAKE_FILES="$GITOPS_ENV_PATH .deps compile install-sh missing AUTHORS ChangeLog INSTALL NEWS COPYING depcomp"

# it's not too bad if these files don't get deleted, thats why they're separate
DEBUG_FILES="config.status config.log autom4te.cache aclocal.m4"

LS_SNAPSHOT=$(ls -a)

ARG_ROLLBACK=yes

# ==============================================================================
# Flag
# ==============================================================================
AC_ARG_WITH([exposed-patch],
            [AS_HELP_STRING([--with-exposed-patch],
                            [Keep the patched ./configure.ac after autoconf @<:@default=no@:>@])],
            [with_exposed_patch_flag=$withval],
            [with_exposed_patch_flag=no])

AC_ARG_WITH([porcelain-git],
            [AS_HELP_STRING([--without-porcelain-git],
                            [do not consider git status @<:@default=no@:>@])],
            [ARG_PORCELAIN_GIT=$withval])

# ==============================================================================
# Macro: check for staged git files
# ==============================================================================
# CHECK_GIT_STATUS([ERROR])
# --------------------------------------
AC_DEFUN([MY_MSG_ERROR], [
    REVERT
    AC_MSG_ERROR([$1])
])

AC_DEFUN([ENFORCE_PORCELAIN_GIT], [
    if test "$ARG_PORCELAIN_GIT" '!=' 'yes'; then
        AC_MSG_ERROR([

            refusing to continue without porcelain git.

            `--without-porcelain-git`, at this point, is illegal.
        ])
    fi
])

# REMOVE_ORPHANED(FILE_LIST)
# --------------------------------------
# Remove auxiliary files that were not present before running this
AC_DEFUN([REMOVE_ORPHANED], [
    for file in $1; do
        if ! test -f $file && ! test -d $file; then
            continue
        fi

        AC_MSG_CHECKING([fate of file './$file'])
        match=0
        for _file in $LS_SNAPSHOT; do
            if test "$_file" '=' "$file"; then
                match=1
            fi
        done

        if test $match -eq 0 && test "$ARG_ROLLBACK" '=' 'yes'; then
            AC_MSG_RESULT([orphan (remove)])
            rm -r $file
        elif test "$ARG_ROLLBACK" '=' 'no'; then
            AC_MSG_RESULT([keep (no rollback)])
        else
            AC_MSG_RESULT([keep])
        fi
    done
])

# REVERT()
# --------------------------------------
AC_DEFUN([REVERT], [
    AC_MSG_NOTICE([reverting...])
    REMOVE_ORPHANED([$AUTOMAKE_FILES])
])

# tell the environment auditor not to snapshot the environment
_QUIET=1

# queue of the environment auditor
GITOPS_ENV_CHECKS=''

printf '=== Git ===\n'
m4_include([configure.ac-git.m4])
printf '=== GitOps ===\n'
m4_include([configure.ac-gitops.m4])
printf '=== Framework ===\n'
m4_include([configure.ac-framework.m4])
printf '=== CI/CD Pipeline ===\n'
m4_include([configure.ac-cicd.m4])
printf '=== Autoconf ===\n'
m4_include([configure.ac-autoconf.m4])
printf '=== Configure ===\n'
m4_include([configure.ac-exec.m4])
printf '=== Environment Audit ===\n'
m4_include([configure.ac-gitops-audit.m4])
printf '=== Automake ===\n'
m4_include([configure.ac-automake.m4])
printf '=== Makefile ===\n'
m4_include([configure.ac-makefile.m4])

AC_OUTPUT

# Call the cleanup macro after configure
AC_CONFIG_COMMANDS_POST([REMOVE_ORPHANED([$AUTOMAKE_FILES])])
AC_CONFIG_COMMANDS_POST([REMOVE_ORPHANED([$DEBUG_FILES])])

dnl# clear the default help message.
m4_cleardivert([HELP_BEGIN])dnl
m4_cleardivert([HELP_CANON])dnl
m4_cleardivert([HELP_ENABLE])dnl
m4_cleardivert([HELP_WITH])dnl
m4_cleardivert([HELP_VAR])dnl
m4_cleardivert([HELP_VAR_END])dnl
m4_cleardivert([HELP_END])dnl

dnl# custom help message with man page
m4_divert_push([HELP_BEGIN])dnl
test "$ac_init_help" '=' "long" && { $(dirname "$(realpath "$0")")/man configure; exit 1; }
m4_divert_pop([HELP_BEGIN])dnl
