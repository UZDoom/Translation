#!/bin/bash

# ./compile.sh ./gzdoom_engine_strings/*.po > gzdoom_engine_strings.csv

SCRIPT="$(dirname "$0")/compile.awk"
FILES="$@"

ls -1 $FILES 2>/dev/null | xargs gawk -f "$SCRIPT"
