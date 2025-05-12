#!/bin/bash

# Script to update the 'revision' field in *.manifest.json files
# tracked by Git to the current Git commit short hash.

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
MANIFEST_SUFFIX=".manifest"

# --- Dependency Check ---
# 1. Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "Error: jq is not installed." >&2
    echo "Please install jq (e.g., 'sudo apt-get install jq' or 'brew install jq') to run this script." >&2
    exit 1
fi

# 2. Check if we are in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not inside a Git repository." >&2
    exit 1
fi

# --- Main Logic ---
# 3. Get the current Git revision (short hash)
CURRENT_REVISION=$(git rev-parse --short HEAD)
if [ $? -ne 0 ]; then
    echo "Error: Failed to get current Git revision." >&2
    exit 1
fi
echo "Current Git Revision: $CURRENT_REVISION"

# 4. Find all *.manifest.json files tracked by Git and loop through them
echo "Finding and updating files ending with ${MANIFEST_SUFFIX}..."
# Use git ls-files to find relevant files tracked by git
# Use process substitution and while read loop for safer filename handling
while IFS= read -r file; do
    # Check if the file actually exists locally (it might be deleted but still in index)
    if [ ! -f "$file" ]; then
        echo "Warning: File '$file' listed by git ls-files does not exist locally. Skipping."
        continue
    fi

    echo "Processing file: $file"
    # Create a temporary file for jq output in the same directory to handle permissions/mounts better
    TMP_FILE=$(mktemp "${file}.tmp.XXXXXX")
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create temporary file for $file. Skipping." >&2
        continue # Skip to the next file
    fi

    # Use jq to update the revision field
    # Pass the git revision as a variable ($rev) to jq
    # The '.revision = $rev' expression updates the value of the 'revision' key
    jq --arg rev "$CURRENT_REVISION" '.revision = $rev' "$file" > "$TMP_FILE"
    JQ_EXIT_CODE=$?

    if [ $JQ_EXIT_CODE -eq 0 ]; then
        # Optional: Basic check if jq produced valid JSON output
        if jq -e . "$TMP_FILE" > /dev/null; then
            # Overwrite the original file with the updated content using cat and redirection
            cat "$TMP_FILE" > "$file"
            # Remove the temporary file
            rm "$TMP_FILE"
            echo "  Updated revision in $file to $CURRENT_REVISION"
        else
            echo "Error: jq produced invalid JSON for $file. Original file not modified." >&2
            rm "$TMP_FILE" # Clean up temp file
        fi
    else
        echo "Error: jq failed to process $file (Exit code: $JQ_EXIT_CODE). Original file not modified." >&2
        # Attempt to remove the temp file even if jq failed
        rm "$TMP_FILE" &> /dev/null || true
    fi
# Feed the loop with filenames from git ls-files, ensuring correct handling of paths
done < <(git ls-files "*${MANIFEST_SUFFIX}")

echo "Script finished."
exit 0