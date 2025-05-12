#!/bin/bash

# Script to update the 'revision' field in *.manifest.json files
# to a specified revision or the current Git commit short hash.
# If a revision argument is provided, it uses 'find' to locate files.
# Otherwise, it uses 'git ls-files' to find files tracked by Git.

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

# 2. Check if we are in a git repository (only needed if not providing revision)
if [ -z "$1" ] && ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not inside a Git repository and no revision argument provided." >&2
    exit 1
fi

# --- Main Logic ---
# 3. Determine the Git revision to use
if [ -n "$1" ]; then
    # Use the first command-line argument if provided
    CURRENT_REVISION="$1"
    USE_FIND=true
    echo "Using provided revision: $CURRENT_REVISION"
    echo "Using 'find' to locate files..."
else
    # Otherwise, get the current Git revision (short hash)
    CURRENT_REVISION=$(git rev-parse --short HEAD)
    if [ $? -ne 0 ]; then
        echo "Error: Failed to get current Git revision." >&2
        exit 1
    fi
    USE_FIND=false
    echo "Using current Git Revision: $CURRENT_REVISION"
    echo "Using 'git ls-files' to locate files..."
fi


# 4. Find and update files based on whether a revision was provided
echo "Finding and updating files ending with ${MANIFEST_SUFFIX}..."

process_file() {
    local file="$1"
    local revision="$2"
    # Check if the file actually exists locally (relevant for both find and git ls-files)
    if [ ! -f "$file" ]; then
        echo "Warning: File '$file' does not exist locally or is not a regular file. Skipping."
        return
    fi

    echo "Processing file: $file"
    # Create a temporary file for jq output in the same directory to handle permissions/mounts better
    local TMP_FILE
    TMP_FILE=$(mktemp "${file}.tmp.XXXXXX")
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create temporary file for $file. Skipping." >&2
        return # Skip to the next file
    fi

    # Use jq to update the revision field
    # Pass the git revision as a variable ($rev) to jq
    # The '.revision = $rev' expression updates the value of the 'revision' key
    jq --arg rev "$revision" '.revision = $rev' "$file" > "$TMP_FILE"
    local JQ_EXIT_CODE=$?

    if [ $JQ_EXIT_CODE -eq 0 ]; then
        # Optional: Basic check if jq produced valid JSON output
        if jq -e . "$TMP_FILE" > /dev/null; then
            # Overwrite the original file with the updated content using cat and redirection
            cat "$TMP_FILE" > "$file"
            # Remove the temporary file
            rm "$TMP_FILE"
            echo "  Updated revision in $file to $revision"
        else
            echo "Error: jq produced invalid JSON for $file. Original file not modified." >&2
            rm "$TMP_FILE" # Clean up temp file
        fi
    else
        echo "Error: jq failed to process $file (Exit code: $JQ_EXIT_CODE). Original file not modified." >&2
        # Attempt to remove the temp file even if jq failed
        rm "$TMP_FILE" &> /dev/null || true
    fi
}

if [ "$USE_FIND" = true ]; then
    # Use find when a revision argument is provided
    # Use -print0 and read -d $'\0' for safe handling of filenames with special characters/spaces
    while IFS= read -d $'\0' -r file; do
        process_file "$file" "$CURRENT_REVISION"
    done < <(find . -name "*${MANIFEST_SUFFIX}" -type f -print0)
else
    # Use git ls-files when no revision argument is provided
    # Use process substitution and while read loop for safer filename handling
    while IFS= read -r file; do
        process_file "$file" "$CURRENT_REVISION"
    done < <(git ls-files "*${MANIFEST_SUFFIX}")
fi

echo "Script finished."
exit 0
