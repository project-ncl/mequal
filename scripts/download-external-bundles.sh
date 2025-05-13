#!/bin/env bash

# Generated with assistance from a large language model trained by Google.

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
# set -u # Optional: uncomment if you want stricter variable handling
# Pipe commands should return the exit status of the last command to exit with a
# non-zero status, or zero if all commands exit successfully.
set -o pipefail

# --- Configuration ---
JSON_FILE="./config/external-bundles.json" # Replace with the actual path to your JSON file
EC_CLI="./binaries/ec-cli" # The name for the downloaded binary

# --- Input Validation ---
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' command not found. Please install jq." >&2
    exit 1
fi

if [[ ! -f "$JSON_FILE" ]]; then
    echo "Error: JSON file not found at '$JSON_FILE'" >&2
    exit 1
fi

bash ./scripts/download-binaries.sh

# --- Logic to Build Arguments ---
cli_args=()
while IFS= read -r uri; do
  if [[ -n "$uri" ]]; then
    cli_args+=("-s" "$uri")
  fi
done < <(jq -r '.[].uri' "$JSON_FILE")

if [[ ${#cli_args[@]} -eq 0 ]]; then
  echo "Warning: No URIs found in '$JSON_FILE' or failed to parse."
fi

# --- Execution ---

# Construct the full command for logging purposes (optional, but helpful)
# Note: Using [*] here for display is okay, but use [@] for actual execution.
echo "Running command: ${EC_CLI} fetch policy ${cli_args[*]}"

# Execute the command: executable first, then fixed args, then dynamic args
# Make sure "${cli_args[@]}" is the LAST part
"${EC_CLI}" fetch policy "${cli_args[@]}"

echo "Command finished."

# --- Exit ---
# The trap will automatically run the cleanup function here upon normal exit.
exit 0