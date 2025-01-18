#!/bin/sh

# Filter a list of file paths. Reads from stdin, writes to stdout
#
# Arguments:
#   $1: Source directory path.
#   $2: Destination directory path.
#   $@: Patterns to match against for overwriting files.
#
# Options:
#   -o pattern to not filter files, regardless on whether they exist at the destination.
#      Also, files not matching this pattern and existing at the destination are
#      filtered.
#
# Description:
#   This function copies the contents of the source directory to the destination directory, but only overwrites files in the destination if they match any of the provided patterns. The function uses the real paths of the source and destination directories to ensure accurate file operations. 
#   If the -o option is provided, the function will only overwrite files in the destination directory if they match any of the specified patterns. If the -o option is not provided, no files will be overwritten.
#
#   Usage example:
#     file__filter /path/to/src /path/to/dest -o "*.txt" -o "*.md"
#
# Returns:
#   0 - if the function executes successfully.
#   1 - if an invalid option is provided or an option requires an argument but none is given.
file__filter() {
    overwrite=''

    while getopts ":o:" opt; do
      case $opt in
        o) overwrite="$overwrite $OPTARG";;
        \?) echo "Invalid option: -$OPTARG" >&2; return 1;;
        :) echo "Option -$OPTARG requires an argument." >&2; return 1;;
      esac
    done

    shift $(expr $OPTIND '-' 1)

    src_dir="$(realpath "$1")"
    dest_dir="$(realpath "$2")"


    while IFS= read -r path; do
        relative_path="$(echo "$(realpath "$path")" | sed "s|$src_dir/||")"
        dest_path="$dest_dir/$relative_path"

        if test -f "$dest_path"; then
            file__globs "$path" "$src_dir" $overwrite
            if test $? -eq 0; then
                echo $relative_path
            fi
        else
            echo $relative_path
        fi
    done
}

# Check if a path matches against any glob patterns
# Arguments:
#   $1: input path
#   $2: base directory to search
#   $@: glob patterns to match against the input path
# Returns:
#   0 - path matches any pattern
#   1 - path matches no pattern
file__globs() {
    input="$( realpath "$1")"; shift
    base_dir="$( realpath "$1")"; shift
    pids=""

    for pattern in "$@"; do
        file__glob "$input" "$base_dir" "$pattern" &
        pids="$pids $!"
    done

    for pid in $pids; do
        wait "$pid"
        exit_status=$?
        if test $exit_status -eq 0; then
            return 0
        fi
    done

    return 1
}


# Check if a path matches against all glob patterns
# Arguments:
#   $1: input path
#   $2: base directory to search
#   $@: glob patterns to match against the input path
# Returns:
#   0 - path matches any pattern
#   1 - path matches no pattern
file__gglobs() {
    base_dir="$( realpath "$1")"; shift
    patterns="$@"
    pids=""


    for pattern in "$@"; do
        file__gglob "$base_dir" "$pattern" &
        pids="$pids $!:$pattern"
    done

    error=0
    for field in $pids; do
        pid="$(echo "$field" | cut -d ':' -f 1)"
        pattern="$(echo "$field" | cut -d ':' -f 2)"
        set +e
        wait "$pid"
        exit_status=$?
        set -e
        if test $exit_status -ne 0; then
            echo "error: no matches for pattern '$pattern'" >&2
            error=1
        fi
    done

    return $error
}


file__gglob() {
    base_dir="$(realpath "$1")"
    pattern="$2"

    if test "$(echo "$pattern" | sed 's|^/||')" '!=' "$pattern"; then
        pattern="$base_dir/$(echo "$pattern" | sed 's|^/||')"
    else
        find "$base_dir" -path "**/$pattern" | grep .
        return $?
    fi

    find "$base_dir" -path "$pattern" | grep .
    return $?
}


# Check if a path matches against a pattern, with .gitignore-like globbing
#
# This function checks if a given input path matches a specified pattern,
# similar to how .gitignore works. It differs from the glob patterns used by
# the find command. In gitignore, patterns like `**` allow for recursive 
# directory matching, whereas find's glob patterns do not inherently handle
# recursive matching without additional options.
#
# Arguments:
#   $1: input path - The path to check against the pattern.
#   $2: base directory - The base directory for the search.
#   $3: glob pattern to match against the input path.
# Returns:
#   0 - path matches glob pattern
#   1 - path does not match glob pattern
#   2 - $2 is not a directory
#   3 - $1 is same as $2#
file__glob() {
    input_path="$1"
    base_dir="$(realpath "$2")"
    pattern="$3"

    if ! test -d "$base_dir"; then
        echo "error: '$base_dir' not a directory." >&2
        return 2
    fi

    recurse=no
    if test "$(realpath $input_path)" '=' "$base_dir"; then
        echo "error: '$base_dir' input path same as lookup path." >&2
        return 3
    # .gitignore-like globbing with implicit recursive exact match
    elif test "$(basename "$input_path")" '=' "$pattern"; then
        recurse=yes
    # .gitignore-like globbing with implicit absolute exact match
    elif test "$(echo "$pattern" | sed 's|^/||')" '!=' "$pattern"; then
        pattern="$base_dir/$(echo "$pattern" | sed 's|^/||')"
    else
        recurse=yes
    fi

    if test "$recurse" '=' 'yes'; then
        find "$base_dir" -path "**/$pattern" | while IFS= read -r result; do
            if test "$result" '=' "$base_dir"; then
                continue
            elif test "$result" '=' "$input_path"; then
                exit 1
            fi
        done;
    fi

    # invert the exit code, so that no find results returns 1
    if test $? -eq 1; then
        return 0
    fi

    # Using POSIX 2008 'path' feature of find
    # This feature is not available in POSIX 2004 and earlier
    find "$base_dir" -path "$pattern" | while IFS= read -r result; do
        if test "$result" '=' "$base_dir"; then
            continue
        elif test "$result" '=' "$input_path"; then
            exit 1
        fi
    done;

    # invert the exit code, so that no find results returns 1
    if test $? -eq 1; then
        return 0
    fi

    return 1
}

# Check if a path is a child of another path
# Arguments:
#   $1: base path
#   $2: path to inspect
# Returns:
#   0 - path is in base path
#   1 - path is not in base path
file__indir() {
    src_dir="$1"
    file="$2"
    # Canonicalize the paths
    abs_src_dir=$(cd "$src_dir" && pwd)
    abs_file=$(cd "$(dirname "$file")" && pwd)/$(basename "$file")

    case "$abs_file" in
        "$abs_src_dir"*) return 0;;
        *)
            echo "error: '$file' outside of '$src_dir'." >&2
            return 1
            ;;
    esac
}
