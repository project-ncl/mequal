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
EC_BINARY_NAME="ec-cli" # The name for the downloaded binary


# --- Determine OS and Architecture for EC_CLI_URL ---
OS_TYPE=$(uname -s)
ARCH_TYPE=$(uname -m)
EC_CLI_RELEASE_TAG="v0.6.159" # Keep the version in one place for easier updates
EC_CLI_BASE_URL="https://github.com/enterprise-contract/ec-cli/releases/download/${EC_CLI_RELEASE_TAG}"

echo "Detected OS: ${OS_TYPE}, Architecture: ${ARCH_TYPE}"

if [[ "$OS_TYPE" == "Linux" ]]; then
    if [[ "$ARCH_TYPE" == "x86_64" || "$ARCH_TYPE" == "amd64" ]]; then
        EC_CLI_URL="${EC_CLI_BASE_URL}/ec_linux_amd64"
    elif [[ "$ARCH_TYPE" == "aarch64" || "$ARCH_TYPE" == "arm64" ]]; then
        # If you also want to support Linux ARM64
        EC_CLI_URL="${EC_CLI_BASE_URL}/ec_linux_arm64"
        echo "Info: Detected Linux ARM64. Ensure this binary is available for the specified version."
    else
        echo "Error: Unsupported Linux architecture: $ARCH_TYPE" >&2
        echo "Please check available binaries at https://github.com/enterprise-contract/ec-cli/releases/tag/${EC_CLI_RELEASE_TAG}" >&2
        exit 1
    fi
elif [[ "$OS_TYPE" == "Darwin" ]]; then # Darwin is the kernel name for macOS
    if [[ "$ARCH_TYPE" == "arm64" ]]; then # Apple Silicon M1/M2/M3 etc.
        EC_CLI_URL="${EC_CLI_BASE_URL}/ec_darwin_arm64"
    elif [[ "$ARCH_TYPE" == "x86_64" ]]; then # Intel-based Macs
        EC_CLI_URL="${EC_CLI_BASE_URL}/ec_darwin_amd64"
    else
        echo "Error: Unsupported macOS architecture: $ARCH_TYPE" >&2
        echo "Please check available binaries at https://github.com/enterprise-contract/ec-cli/releases/tag/${EC_CLI_RELEASE_TAG}" >&2
        exit 1
    fi
else
    echo "Error: Unsupported Operating System: $OS_TYPE" >&2
    echo "This script currently supports Linux and macOS (Darwin) for ec-cli downloads." >&2
    echo "Please check available binaries at https://github.com/enterprise-contract/ec-cli/releases/tag/${EC_CLI_RELEASE_TAG}" >&2
    exit 1
fi

echo "Using EC_CLI_URL: ${EC_CLI_URL}"



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
if [[ ! -f "./${EC_BINARY_NAME}" ]]; then
    echo "Enterprise Contract CLI (${EC_BINARY_NAME}) not found. Downloading..."
    if ! command -v curl &> /dev/null; then
        echo "Error: 'curl' command not found. Please install curl." >&2
        exit 1
    fi
    curl -sSfL "${EC_CLI_URL}" -o "${EC_BINARY_NAME}"
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
else
    echo "Enterprise Contract CLI (${EC_BINARY_NAME}) already exists. Skipping download."
    # Ensure it's executable if it already exists, in case permissions were changed
    if [[ ! -x "./${EC_BINARY_NAME}" ]]; then
        echo "Making existing ${EC_BINARY_NAME} executable..."
        chmod +x "./${EC_BINARY_NAME}"
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to make existing ${EC_BINARY_NAME} executable." >&2
            # set -e handles exit
        fi
    fi
fi

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