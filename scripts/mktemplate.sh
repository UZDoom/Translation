#!/bin/bash

# Dependency check
if ! command -v msgfilter &> /dev/null; then
    echo "Error: 'msgfilter' (gettext) is not installed."
    exit 1
fi

# Find all 'en_US.po' files recursively
find . -type f -name "en_US.po" | while read -r po_file; do
    dir_path=$(dirname "$po_file")
    pot_file="$dir_path/template.pot"

    echo "Processing: $po_file -> $pot_file"

    if command -v msgattrib &> /dev/null; then
         msgattrib --no-obsolete "$po_file" | \
         msgfilter --keep-header -o "$pot_file" sed -e 's/.*//'
    else
         # Fallback if msgattrib is missing entirely
         msgfilter --keep-header -i "$po_file" -o "$pot_file" sed -e 's/.*//'
    fi

    sed -i '1,/^$/ {
        s/^\("[^:]*: \).*/\1\\n"/
        s/^"[^:]*"$/""/
        /^""$/d
        /^"X-.*: /d
        s/^\("Project-Id-Version:\).*"/\1 1.0\\n"/
        s/^\("MIME-Version:\).*"/\1 1.0\\n"/
        s/^\("Content-Transfer-Encoding:\).*"/\1 8bit\\n"/
        s/^\("Content-Type:\).*"/\1 text\/plain; charset=utf-8\\n"/
    }' "$pot_file"
done
