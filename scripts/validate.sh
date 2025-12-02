#!/bin/bash

if ! command -v msgfmt &> /dev/null
then
	echo "Error: 'msgfmt' (gettext) is not installed."
	exit 1
fi

error_count=0

while IFS= read -r file
do
	if output=$(msgfmt --check --output-file /dev/null "$file" 2>&1)
	then
		echo "[OK] $file"
		continue
	fi

	echo "[FAIL] $file"
	echo "$output" | sed 's/^/  /' # indent
	((error_count++))
done < <(find . -type f -name "*.po")

if [ "$error_count" -gt 0 ]
then
	echo ""
	echo "Validation failed for $error_count file(s)."
	exit 1
fi

echo "All files valid."
