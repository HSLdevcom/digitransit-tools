#!/usr/bin/env bash

# This script reads unscoped route ids from stdin and
# outputs a valid JSON array 

FEED_SCOPE=${1:-HSL}

# Check to see if a pipe exists on stdin.
if [ -p /dev/stdin ]; then
    echo "["
    FIRST=1
    # read the input line by line
    while IFS= read -r LINE; do
        # comma
        if [ $FIRST -eq 0 ]; then
            echo ","
        else
            FIRST=0
        fi
        echo -n '  "'"$FEED_SCOPE:$LINE"'"'
    done
    echo
    echo "]"
    # Or if we want to simply grab all the data, we can simply use cat instead
    # cat
else
    >&2 echo "No input was found on stdin, skipping!"
fi
