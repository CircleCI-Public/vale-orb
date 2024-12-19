#!/bin/sh

DIR="."
REGEX="^$DIR/"
FILES=()
while read -r file; do
    if [[ "$file" =~ $REGEX || "$DIR" = "." || "$DIR" = "$PWD" ]]; then
        FILES+=("$file")
    fi
done <<EOF
$(git diff --name-only --diff-filter=d main)
EOF
echo "${FILES[@]}"