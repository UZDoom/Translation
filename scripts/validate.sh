#!/bin/bash

if ! command -v msgfmt &> /dev/null
then
	echo "Error: 'msgfmt' (gettext) is not installed."
	exit 1
fi

error_count=0

while IFS= read -r file
do
	output=$(msgfmt --check --output-file /dev/null "$file" 2>&1)

	output=$(grep -v "entries do not both end with '\\\\n'$" <<< "$output") # monolingual, so this error is invalid
	output=$(grep -v "^msgfmt: found [0-9]" <<< "$output") # the count will be wrong, so remove

	errors=$(grep -v ": warning: " <<< "$output")

	if [ -z "$errors" ]
	then
		echo "[OK] $file"
	else
		echo "[FAIL] $file"
		((error_count++))
	fi

	if [ -n "$output" ]
	then
		echo "$output" | sed 's/^/  /' # indent
	fi
done < <(find . -type f -name "*.po")

if [ "$error_count" -gt 0 ]
then
	echo ""
	echo "Validation failed for $error_count file(s)."
	exit 1
fi

echo "All files valid."
