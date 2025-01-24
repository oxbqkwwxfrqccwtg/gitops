#!/usr/bin/env sh

#
# basic parse for nested mappings of a YAML document that can be chained for 
# recursive-descent. We have to keep it POSIX, so CLI parsers like 'yq' are out 
# of the question. But I came to figure, we don't need a full-fledged parser.
yaml__get_nested_mappings() {

    in=no
    lineno=0
    tabs=
    softtabs=
    indent=

    section_name="$1"

    #TODO: rewrite the communication between subprocesses and main process
    signal=$(mktemp)
    printf "no" > $signal

    while IFS= read -r line; do
        lineno=$(expr $lineno '+' 1)

        section=$(echo "$line" | sed -E 's|[ \t]*$||' | sed 's|:$||')
        if test "$section" '!=' "$line" && test "$(echo "$section" | sed -E 's|^[ \t]+||')" '=' "$section"; then
            if test "$section" '=' "$section_name"; then
                printf "yes" > $signal
                continue
            elif test "$(cat "$signal")" '=' 'yes'; then
                break
            fi
        fi

        #count the indentation of the first line with at least one
        #non-whitespace character, this is the base indentation level
        if test -z "$indent" && test "$(echo $line | sed -E 's|^[ \t]+[A-Za-z0-9_-]||')" '!=' "$line"; then
            _IFS=$IFS
            unset IFS
            for char in "$(echo "$line" | sed -E 's|[A-Za-z0-9_-].*$||')"; do
                tabs="$tabs$char"
                if ! test "$char" '=' ' '; then
                    softtabs="$softtabs    "
                else
                    softtabs="$softtabs"
                fi
           done
           IFS=_IFS; unset _IFS

           indent=yes
        fi

        #empty lines
        if test -z "$(echo "$line" | sed -E 's|[ \t]+||')"; then
            echo "$line"
            continue
        fi

        deindent="$(echo "$line" | sed "s|^$tabs||")"
        test "$deindent" '=' "$line" && deindent="$(echo "$line" | sed "s|^$softtabs||")"

        echo "$deindent"

        test "$(cat "$signal")" '!=' 'yes' && continue

        name="$(echo "$deindent" | sed -E 's|:[ \t]*$||' | cut -d ':' -f '1')"

        if test "$name" "=" "$(echo "$name" | sed -E 's|^[ \t]*||')" && test "$(cat "$signal")" '=' 'yes'; then
            if ! test -z "$out"; then
                _lineno=$(echo "$out" | cut -d ':' -f 1)
                _name="$(echo "$out" | sed -E 's|[0-9]+:||')"
                echo "$_lineno:$(expr $lineno '-' 1):$_name" >&2
            fi
            out="$lineno:$name"
        fi
    done

    if ! test -z "$out"; then
        _lineno=$(echo "$out" | cut -d ':' -f 1)
        _name="$(echo "$out" | sed -E 's|[0-9]+:||')"
        echo "$_lineno:$(expr $lineno '-' '1'):$_name" >&2
    fi

    return 0
}


yaml__get_mapping_keys() {

    lineno=0

    while IFS= read -r line; do
        lineno=$(expr $lineno '+' 1)

        # drop any line starting with a whitespace character
        test "$(echo "$line" | sed -E 's|^[ \t]+||')" '!=' "$line" && continue

        name="$(echo "$line" | sed -E 's|:.*$||')"

        #drop any line that is not a (rooted) mapping
        test "$name" '=' "$line" && continue

        echo "$line"

        if ! test -z "$out"; then
            _lineno=$(echo "$out" | cut -d ':' -f 1)
            _name="$(echo "$out" | sed -E 's|[0-9]+:||')"
            echo "$_lineno:$(expr $lineno '-' '1'):$_name" >&2
        fi
        out="$lineno:$name"
    done

    if ! test -z "$out"; then
        _lineno=$(echo "$out" | cut -d ':' -f 1)
        _name="$(echo "$out" | sed -E 's|[0-9]+:||')"
        echo "$_lineno:$(expr $lineno):$_name" >&2
    fi

    return 0
}


yaml__get_array_keys() {

    lineno=0

    i=0

    while IFS= read -r line; do
        lineno=$(expr $lineno '+' 1)

        # drop any line starting with a whitespace character
        test "$(echo "$line" | sed -E 's|^[ \t]+||')" '!=' "$line" && continue

        name="$(echo "$line" | sed -E 's|:.*$||')"

        #drop any line that is not a (rooted) mapping
        test "$name" '=' "$line" && continue

        echo "$line"

        if ! test -z "$out"; then
            _lineno=$(echo "$out" | cut -d ':' -f 1)
            _name="$(echo "$out" | sed -E 's|[0-9]+:||')"
            echo "$_lineno:$(expr $lineno '-' '1'):$_name" >&2
        fi
        out="$lineno:$i"

        i=$(expr $i '+' 1)
    done

    if ! test -z "$out"; then
        _lineno=$(echo "$out" | cut -d ':' -f 1)
        _name="$(echo "$out" | sed -E 's|[0-9]+:||')"
        echo "$_lineno:$(expr $lineno):$_name" >&2
    fi

    return 0
}


yaml__get_mapping_value() {
    key="$1"

    while IFS= read -r line; do
        lineno=$(expr $lineno '+' 1)

        # drop any line starting with a whitespace character
        test "$(echo "$line" | sed -E 's|^[ \t]+||')" '!=' "$line" && continue

        name="$(echo "$line" | sed -E 's|:.*$||')"

        #drop any line that is not a (rooted) mapping
        test "$name" '=' "$line" && continue

        test "$name" '!=' "$key" && continue

        value="$(echo "$line" | sed -E 's|^[A-Za-z0-9_-]+:[ \t]*||')"

        if test -z "$value"; then
            echo "error: '$name' mapping has an empty value and is probably a nested mapping." >&2
            echo "Call \`yaml__get_nested_mappings\` instead." >&2
            return 1
        fi

        echo "$line"

        echo "$lineno:$value" >&2
    done

    return 0
}
