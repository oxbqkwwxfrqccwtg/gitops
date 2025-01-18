#!/usr/bin/env sh

semver__parse() {
    if test -z "$1"; then
        echo "error: undefined \$1: semver_string" >&2
        return 1
    fi

    semver_string="$(echo "$1" | sed 's|^v||')"

    major=$(echo "$semver_string" | cut -d '.' -f 1)
    minor=$(echo "$semver_string." | cut -d '.' -f 2)
    patch=$(echo "$semver_string.." | cut -d '.' -f 3)
    subversion=$(echo "$semver_string..." | cut -d '.' -f 4)

    if test -z "$major"; then
        echo "error: unable to parse major version" >&2
        return 2
    elif test -z "$minor"; then 
        echo "error: unable to parse minor version" >&2
        return 3
    elif test -z "$patch"; then 
        echo "error: unable to parse patch version" >&2
        return 4
    elif ! test "$(echo "$major" | sed -E 's|^[0-9]+$||')" '=' ''; then
        echo "error: major version not a number ('$major')" >&2
        return 5
    elif ! test "$(echo "$minor" | sed -E 's|^[0-9]+$||')" '=' ''; then
        echo "error: minor version not a number ('$major')" >&2
        return 6
    fi

    suffix="$(echo "$patch" | sed -E "s|^[0-9]+||")"
    patch="$(echo "$patch" | sed "s|$suffix$||")"
    if ! test "$(echo "$patch" | sed -E 's|^[0-9]+$||')" '=' ''; then
        echo "error: patch version not a number" >&2
        return 7
    fi

    subtype="$(echo "$suffix" | sed -E 's|^\-||' | sed -E 's|\..*$||')"

    if ! test -z "$subversion" && ! test "$(echo "$subversion" | sed -E 's|^[0-9]+$||')" '=' ''; then
        echo "subversion not a number" >&2
        return 8
    fi

    echo "$major $minor $patch $subtype $subversion"
    return 0
}

semver__upgrade() {
    kind="$1"
    semver_string="$(semver__parse "$(echo "$2" | sed 's|^v||')")"

    major=$(echo "$semver_string" | cut -d ' ' -f 1)
    minor=$(echo "$semver_string " | cut -d ' ' -f 2)
    patch=$(echo "$semver_string  " | cut -d ' ' -f 3)
    subtype=$(echo "$semver_string   " | cut -d ' ' -f 4)
    subversion=$(echo "$semver_string    " | cut -d ' ' -f 5)

    case $kind in
        'major') 
            major=$(expr $major '+' 1)
            minor=0
            patch=0
            subversion=
            subtype=
            break
            ;;
        'minor')
            minor=$(expr $minor '+' 1)
            patch=0
            subversion=
            subtype=
            break
            ;;
        'patch')
            patch=$(expr $patch '+' 1)
            subversion=
            subtype=
            break
            ;;
        *)

            if test "$subtype" '=' "$kind"; then
                subversion=$(expr $subversion '+' 1)
            else
                subtype="$kind"
                subversion=0
            fi

            test $subversion -eq 0 && unset subversion

            break
            ;;
    esac

    printf "v$major.$minor.$patch"

    if ! test -z "$subtype"; then
        printf '-'
        printf "$subtype"
    fi

    if ! test -z "$subtype" && ! test -z "$subversion"; then
        printf ".$subversion"
    fi

    echo ""

    unset kind semver_string major minor patch subtype subversion
}
