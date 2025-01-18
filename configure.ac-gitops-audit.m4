if test -z "$GITOPS_PATH"; then
    AC_MSG_ERROR([
        The environment variable 'GITOPS_PATH' is not set. This is a 
        programming error of the program, contact the program's maintainer.
    ])
fi

if test -z "$GITOPS_ENV_PATH"; then
    AC_MSG_ERROR([
        The environment variable 'GITOPS_ENV_PATH' is not set. This is a 
        programming error of the program, contact the program's maintainer.
    ])
fi

AC_MSG_NOTICE([checking shell environment...])

for property in $(printf "$GITOPS_ENV_CHECKS"); do

    test -z "$property" && continue

    ns=$(echo "$property" | cut -d ':' -f 1)
    obj=$(echo "$property:" | cut -d ':' -f 2)
    name=$(echo "$property::" | cut -d ':' -f 3)
    default=$(echo "$property:::" | cut -d ':' -f 4)

    if test -z "$ns" || test -z "$obj" || test -z "$name"; then
        AC_MSG_ERROR([programming

This is a programming error and this is the environment auditor throwing it.

Citizen, move along, I need to talk to the maintainer.

I've thrown this error in '$(realpath $0)', here's the story:

I check for required and optional shell environment variables by 
dequeuing the new-line separated mappings of the 'GITOPS_ENV_CHECKS' 
shell environment variable to give every component of GitOps a chance
to require shell environment variables to be set or set a default 
value.

In addition, I snapshot the environment into '$GITOPS_ENV_PATH'.

Checks are enqueued by appending mappings to the 'GITOPS_ENV_CHECKS' 
shell environment variable.

A mapping is structured like this:

    `<component>:<type>:<name>:<default>`

component - the GitOps component that enqueued the check
type      - the type of the GitOps component that the check is enqueued for
name      - the name of the variable to check
default   - the default value to set for the variable

Essentially, with a mapping you can check for required and optional 
shell environment variables:

    'required' example: `framework:foobar:FOOBAR_ENV`

    'optional' example: `framework:foobar:FOOBAR_ENV:my_default`

Here are some examples of highly illegal mappings I came across throughout my 
career:

    `framework:foobar`

    `framework`

    `FOOBAR_ENV`

So i'm doing my regular checks, and then I find this and it has your
fingerprints all over:

    `$property`

Monster! This is a crime against maintainability, you're going straight to 
FreeBSD jail! So that you understand the reason why:

The point of the mappings is to be able identify the origin of the request to
check for environment variables. Without it, if let's say the foobar framework
enqueued a check for `BAD_ENV`, and cicd foobar enqueued a check for `BAD_ENV2`,
there would be no way of telling who requested the check. This is a maintenance
nightmare and you will be judged harshly.

Yes, maintainers are requested to do proper namespacing for environment
variables (e.g. CICD_FOOBAR__GOOD_ENV), but this is currently not enforceable.

That's why we are doing this, and that's why you are seeing this error message
and are now coming with us, to jail!

I dare you to commit this, think about what you did! We've got some water-proof
evidence:

GITOPS_ENV_CHECKS="$GITOPS_ENV_CHECKS"
        ])
    fi

    required=no
    if test -z "$default"; then
        required=yes
    else
        eval "$name="$default""
    fi

    AC_MSG_CHECKING([[[$ns:$obj]] $name])

    set -f

    if test -z "$(eval echo \$$name)"; then
        AC_MSG_RESULT([not set])
        # throwing this weird exit code, so that when it's returned we can be
        # 99.22% sure, that just the checks failed and nothing else. So don't
        # catch all non-zero exit codes, just 123, in order to have a more
        # granular error
        AC_MSG_ERROR([missing_env_variable

Oopsie. You're missing something in your shell environment.

The required environment variable '$name' is not set. It is requested by '$obj'
$ns.
        ], [123])
    else
        AC_MSG_RESULT([$(eval echo "\$$name")])

        # snapshot environment variable
        if test -z "$_QUIET"; then
            AC_MSG_NOTICE([$name >> $GITOPS_ENV_PATH])
            set -e
            echo "export $name=\"$(eval "echo $(echo "\$$name")")\"" >> $GITOPS_ENV_PATH
            set +e
        fi
    fi

    set +f
done

if test -z "$_QUIET"; then
    echo "export GITOPS_PATH=$(echo $GITOPS_PATH | sed 's|^$(pwd)||')" >> $GITOPS_ENV_PATH
fi
