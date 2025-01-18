#!/usr/bin/env sh
test -z "$LIBDIR" && { echo "errors: 'LIBDIR' not set" >&2; exit 1; }
. "$LIBDIR"/file.sh

framework__is() {
    path=$1

    if test -z "$path"; then 
        echo "error: no path specified" >&2
        return 1
    fi

    if ! test -d "$path" && ! test -L "$path" && ! test -f "$(readlink $path)"; then 
        echo "error: path '$1' is not a directory" >&2
        return 2
    fi

    if ! test -f "$path/configure.ac"; then
        echo "error: not implemented: framework 'configure.ac' for '$1'" >&2
        return 3
    elif ! test -f "$path/Makefile.am" && ! test -f "$path/Makefile"; then
        echo "error: not implemented: framework 'Makefile[.am]?' for '$1'" >&2
        return 4
    fi

    return 0
}

framework__list() {
    path=$1

    if test -z "$path"; then 
        echo "error: no path specified" >&2
        return 1
    fi

    ls "$path" | while IFS= read -r name; do
        full_path="$path/$name"

        ! test -d "$full_path" && continue

        framework__is "$full_path"
        test $? -ne 0 && continue

        echo "$full_path"
    done
}

framework__apply() {
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

    framework_path="$(realpath $1)"

    patch_file_basename='patch-files.txt'
    patch_file="$framework_path/$patch_file_basename"

    set -e
    framework__is "$framework_path"
    set +e

    overwrites='-o /configure.ac -o /Makefile -o /Makefile.am'
    if test -f "$patch_file"; then
        for overwrite in $(cat $patch_file); do
            overwrites="$overwrites -o $overwrite"
        done
    fi

    find "$framework_path" -path '*' -follow -type f | \
        file__filter $overwrites "$framework_path" "$target_path" | \
            while IFS= read -r file; do

                test "$file" '=' "patch-files.txt" && continue

                dest_path="$target_path/$file"

                echo "cp: $dest_path"

                cp "$framework_path/$file" "$dest_path"
            done
}

framework__init() {
    path=$1; shift

    if test -z "$path"; then 
        echo "error: no path specified" >&2
        return 1
    fi

    set -e
    framework__is "$path"
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

