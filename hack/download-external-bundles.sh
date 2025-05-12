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
EC_CLI_URL="https://github.com/enterprise-contract/ec-cli/releases/download/v0.6.159/ec_linux_amd64"
EC_BINARY_NAME="ec" # The name for the downloaded binary

# --- Cleanup Function ---
cleanup() {
  echo "Cleaning up..."
  rm -f "./${EC_BINARY_NAME}" # Use -f to avoid errors if file doesn't exist
}

# --- Trap ---
trap cleanup EXIT

# --- Input Validation ---
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' command not found. Please install jq." >&2
    exit 1
fi

if [[ ! -f "$JSON_FILE" ]]; then
    echo "Error: JSON file not found at '$JSON_FILE'" >&2
    exit 1
fi

# --- Download and Prepare Binary ---
echo "Downloading Enterprise Contract CLI from ${EC_CLI_URL}..."
if ! command -v wget &> /dev/null; then
    echo "Error: 'wget' command not found. Please install wget or modify script to use curl." >&2
    exit 1
fi
wget --quiet --show-progress "${EC_CLI_URL}" -O "${EC_BINARY_NAME}"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to download ${EC_BINARY_NAME}" >&2
    # set -e handles exit
fi

echo "Making ${EC_BINARY_NAME} executable..."
chmod +x "./${EC_BINARY_NAME}"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to make ${EC_BINARY_NAME} executable." >&2
    # set -e handles exit
fi
echo "Download and preparation complete."

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
# Define CLI_TOOL as JUST the path to the executable
CLI_TOOL="./${EC_BINARY_NAME}"

# Construct the full command for logging purposes (optional, but helpful)
# Note: Using [*] here for display is okay, but use [@] for actual execution.
echo "Running command: ${CLI_TOOL} fetch policy ${cli_args[*]}"

# Execute the command: executable first, then fixed args, then dynamic args
# Make sure "${cli_args[@]}" is the LAST part
"${CLI_TOOL}" fetch policy "${cli_args[@]}"

echo "Command finished."

# --- Exit ---
# The trap will automatically run the cleanup function here upon normal exit.
exit 0