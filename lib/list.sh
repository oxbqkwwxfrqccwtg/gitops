#!/bin/sh

# list_slice - Extracts a slice of a list passed as stdin
#
# Usage:
#   array_slice -s START_INDEX [-e END_INDEX] < input.txt
#   echo "item1 item2 item3 item4" | array_slice -s 1 -e 3
#
# Options:
#   -s START_INDEX  Index to start slicing from (0-based)
#   -e END_INDEX    Index to stop slicing at (0-based, exclusive). If END_INDEX
#                   is greater than the list length, the function will slice
#                   up to the end of the array.
#
# Description:
#   This function reads from stdin and extracts a slice of a list  based on
#   the provided start and end indices. If END_INDEX is not provided, it
#   slices until the end of the input. The extracted items are printed to stdout.
#
# Example:
#   $ echo -e "item1\nitem2\nitem3\nitem4" | list_slice -s 1 -e 3
#   item2
#   item3
list__slice() {
    start=0
    while getopts ":s:e:" opt; do
      case $opt in
        s) start=$OPTARG;;
        e) end=$OPTARG;;
        \?) echo "Invalid option: -$OPTARG" >&2; return 1;;
        :) echo "Option -$OPTARG requires an argument." >&2; return 1;;
      esac
    done

    shift $(expr $OPTIND '-' 1)

    i=0
    while IFS= read -r item; do
        if test $i -ge $start; then
            if test -z "$end"; then
                echo "$item"
            else
                if test $i -eq $end; then
                    break
                elif test $i -lt $end; then
                    echo "$item"
                fi
            fi
        fi
        i=$(expr $i '+' 1)
    done
}


