#!/usr/bin/env sh
test -z "$LIBDIR" && { echo "errors: 'LIBDIR' not set" >&2; exit 1; }
. "$LIBDIR"/file.sh

cicd__apply() {
    target_path='.'
    while getopts ":t:" opt; do
      case $opt in
        t) target_path="$OPTARG";;
        \?) echo "Invalid option: -$OPTARG" >&2; return 1;;
        :) echo "Option -$OPTARG requires an argument." >&2; return 1;;
      esac
    done

    shift $(expr $OPTIND '-' 1)

    if test -z "$1"; then
        echo "error: no path specified" >&2
        return 1
    fi

    cicd_path="$(realpath $1)"

    patch_file_basename='patch-files.txt'
    patch_file="$cicd_path/$patch_file_basename"

    set -e
    cicd__is "$cicd_path"
    set +e

    for mapping in $(cicd__vars "$path"); do
        name="$(echo $mapping | cut -d ':' -f 1)"
        default="$(echo "$mapping:" | cut -d ':' -f 2)"

        test -z "$name" && continue

        required=no
        if test -z "$default"; then
            required=yes
        else
            eval "$name="$default""
        fi

        if test -z "$(eval echo \$$name)"; then
            echo "error: missing configuration environment variable '$name'."
            return 1
        fi
    done

    #files that will be overwritten, if they exist at the destination
    overwrites=''
    if test -f "$patch_file"; then
        for overwrite in $(cat $patch_file); do
            overwrites="$overwrites -o $overwrite"
        done
    fi

    find "$cicd_path" -path '*' -follow -type f | \
        file__filter $overwrites "$cicd_path" "$target_path" | \
            while IFS= read -r file; do

                test "$file" '=' "patch-files.txt" && continue

                dest_path="$target_path/$file"

                echo "cp: $dest_path"

                cp "$cicd_path/$file" "$dest_path"
            done
}

cicd__args() {
    path="$1"

    cicd__is "$path"

    cat "$path/args.txt" | while IFS= read -r line; do
        echo "$line"
    done
}

cicd__init() {
    path=$1; shift

    if test -z "$path"; then 
        echo "error: no path specified" >&2
        return 1
    fi

    set -e
    cicd__is "$path"
    set +e

    name="$(basename $path)"

    initializer="$path/../$name.init.sh"
    if test -f "$initializer"; then
        sh $initializer
        return $?
    else
        echo "'$name' has no initializer, nothing to initialize." >&2
        return 0
    fi
}

cicd__is() {
    _path="$path"
    path=$1

    if test -z "$path"; then 
        echo "error: no path specified" >&2
        return 1
    fi

    if ! test -d "$path" && ! test -L "$path" && ! test -f "$(readlink $path)"; then 
        echo "error: path '$1' is not a directory" >&2
        return 2
    fi

    if ! test -f "$path/vars.txt"; then
        echo "error: not implemented: CI/CD pipeline '$path/vars.txt' for '$1'" >&2
        return 3
    elif ! test -f "$path/args.txt"; then
        echo "error: not implemented: CI/CD pipeline '$path/args.txt' for '$1'" >&2
        return 4
    elif ! test -f "$path/detect.sh"; then
        echo "error: not implemented: CI/CD pipeline '$path/detect.sh' for '$1'" >&2
        return 5
    fi

    least_workflow=no
    for workflow in $(find "$path" -path '*' -type d); do
        test "$workflow" '=' "$path" && continue
        if ! test -f "$workflow/render.sh"; then
            echo "error: not implemented: '$workflow/render.sh' for '$1'" >&2
            return 6
        fi
        least_workflow=yes
    done

    if test "$least_workflow" '=' 'no'; then
        echo "error: not implemented: CI/CD pipeline '$path' implements no workflow" >&2
        return 7
    fi

    path="$_path"
    return 0
}

cicd__list() {
    path="$1"

    if test -z "$path"; then 
        echo "error: no path specified" >&2
        return 1
    fi

    ls "$path" | while IFS= read -r name; do

        full_path="$path/$name"

        ! test -d "$full_path" && continue

        cicd__is "$full_path"
        test $? -ne 0 && continue

        echo "$full_path"
    done
}

cicd__vars() {
    path="$1"

    cicd__is "$path"

    cat "$path/vars.txt" | while IFS= read -r line; do
        echo "$line"
    done
}

cicd__workflows() {
    path="$1"

    workflows=''

    for cicd in $(cicd__list "$path"); do
        for workflow in $(find "$cicd" -type d); do
            test "$workflow" '=' "$cicd" && continue

            workflows="$workflows\n$(basename $workflow)"
        done
    done

    printf "$workflows\n" | sort | uniq | tail -n +2
}

cicd__detect() {
    path="$1"

    least=no
    for cicd in $(cicd__list "$path"); do
        set +e
        sh $cicd/detect.sh >/dev/null
        if test $? -eq 0; then
            echo "$(basename "$cicd")"
            least=yes
        fi
        set -e
    done

    test "$least" '=' 'no' && return 1

    return 0
}
