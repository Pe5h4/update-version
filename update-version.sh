#!/bin/bash

# Ensure the script contains arguments
if [[ $# -lt 2 ]]; then
	echo "Usage: $0 <library_name> <new_version>"
	exit 1
fi

LIBRARY_NAME="$1"
NEW_VERSION="$2"

SUCCESFUL_UPDATES=0

echo "Updating '$LIBRARY_NAME' to version '$NEW_VERSION' in all package.json files..."

# Find all package.json files in the monorepo (excluding node_modules)
PACKAGE_JSON_FILES=$(find . -type f -name "package.json" -not -path "*/node_modules/*")
PACKAGE_COUNT=$(echo "$PACKAGE_JSON_FILES" | wc -l)

# Loop through each package.json file and update only the required dependency
for file in $PACKAGE_JSON_FILES; do
	echo "Checking $file"

	# Ensure the file contains the specified library before modifying
	if grep -q "\"$LIBRARY_NAME\"" "$file"; then
		echo "  🔄 Updating $LIBRARY_NAME to version $NEW_VERSION"

		# Update the version without modifying formatting
		sed -i -E "s/(\"$LIBRARY_NAME\": *\")([^\"]+)(\")/\1$NEW_VERSION\3/" "$file"

		((SUCCESFUL_UPDATES++)) # Increment successful updates

		echo "✅ Updated $file"
	else
		echo "  ⚠️  $LIBRARY_NAME not found in $file"
	fi
done

echo "" # Empty line
echo "✨ $SUCCESFUL_UPDATES of $PACKAGE_COUNT package.json files have been updated!"
