#!/bin/sh
set -e

makefile__get_targets() {
    #TODO: fix 'sed: can't read confdefs.h: No such file or directory' error
    targets=$(make -qp | awk -F':' '/^[^.#\t=]+:([^=]|$)/ {print $1}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^%' | grep -v '^Makefile$' | grep -v '[(]' | sort)

    if [ -z "$targets" ] || [ "$targets" = "makefile GNUmakefile" ] || [ "$targets" = "GNUmakefile makefile" ]; then
        return 1
    else
        echo $targets
    fi

}

# Function to check if a list of targets is defined in the Makefile
makefile__check_targets() {
    targets="$@"
    make_targets=$(makefile__get_targets)

    set +e
    for target in $targets; do
        match=0
        for atarget in $make_targets; do
            if [ "$target" '=' "$atarget" ]; then
                match=1
            fi
        done
        if [ $match -ne 1 ]; then
            echo "error: Makefile target '$target' is not defined" 1>&2
            return 1
        fi
    done
    set -e
    echo $make_targets
    return 0
}

