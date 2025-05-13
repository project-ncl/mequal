#!/bin/bash
set -x

# CREATE BINARIES DIR

BINARY_DIR="./binaries"
mkdir -p $BINARY_DIR


# DOWNLOAD OPA CLI

OPA_BINARY_NAME="opa-cli" # The name for the downloaded binary


# --- Determine OS and Architecture for EC_CLI_URL ---
OS_TYPE=$(uname -s)
ARCH_TYPE=$(uname -m)
OPA_RELEASE_TAG="v1.2.0" # Keep the version in one place for easier updates
OPA_BASE_URL="https://github.com/open-policy-agent/opa/releases/download/${OPA_RELEASE_TAG}"

echo "Detected OS: ${OS_TYPE}, Architecture: ${ARCH_TYPE}"

if [[ "$OS_TYPE" == "Linux" ]]; then
    if [[ "$ARCH_TYPE" == "x86_64" || "$ARCH_TYPE" == "amd64" ]]; then
        OPA_URL="${OPA_BASE_URL}/opa_linux_amd64"
    elif [[ "$ARCH_TYPE" == "aarch64" || "$ARCH_TYPE" == "arm64" ]]; then
        # If you also want to support Linux ARM64
        OPA_URL="${OPA_BASE_URL}/opa_linux_arm64_static"
        echo "Info: Detected Linux ARM64. Ensure this binary is available for the specified version."
    else
        echo "Error: Unsupported Linux architecture: $ARCH_TYPE" >&2
        echo "Please check available binaries at https://github.com/open-policy-agent/opa/releases/tag/${OPA_RELEASE_TAG}" >&2
        exit 1
    fi
elif [[ "$OS_TYPE" == "Darwin" ]]; then # Darwin is the kernel name for macOS
    if [[ "$ARCH_TYPE" == "arm64" ]]; then # Apple Silicon M1/M2/M3 etc.
        OPA_URL="${OPA_BASE_URL}/opa_darwin_arm64_static"
    elif [[ "$ARCH_TYPE" == "x86_64" ]]; then # Intel-based Macs
        OPA_URL="${OPA_BASE_URL}/opa_darwin_amd64"
    else
        echo "Error: Unsupported macOS architecture: $ARCH_TYPE" >&2
        echo "Please check available binaries at https://github.com/open-policy-agent/opa/releases/tag/${OPA_RELEASE_TAG}" >&2
        exit 1
    fi
else
    echo "Error: Unsupported Operating System: $OS_TYPE" >&2
    echo "This script currently supports Linux and macOS (Darwin) for ec-cli downloads." >&2
    echo "Please check available binaries at https://github.com/open-policy-agent/opa/releases/tag/${OPA_RELEASE_TAG}" >&2
    exit 1
fi

echo "Using OPA_URL: ${OPA_URL}"


# --- Download and Prepare Binary ---
if [[ ! -f "${BINARY_DIR}/${OPA_BINARY_NAME}" ]]; then
    echo "OPA CLI (${OPA_BINARY_NAME}) not found. Downloading..."
    if ! command -v curl &> /dev/null; then
        echo "Error: 'curl' command not found. Please install curl." >&2
        exit 1
    fi
    curl -sSfL "${OPA_URL}" -o "${BINARY_DIR}/${OPA_BINARY_NAME}"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download ${OPA_BINARY_NAME}" >&2
        # set -e handles exit
    fi

    echo "Making ${OPA_BINARY_NAME} executable..."
    chmod +x "${BINARY_DIR}/${OPA_BINARY_NAME}"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to make ${OPA_BINARY_NAME} executable." >&2
        # set -e handles exit
    fi
    echo "Download and preparation complete."
else
    echo "OPA CLI (${OPA_BINARY_NAME}) already exists. Skipping download."
    # Ensure it's executable if it already exists, in case permissions were changed
    if [[ ! -x "${BINARY_DIR}/${OPA_BINARY_NAME}" ]]; then
        echo "Making existing ${OPA_BINARY_NAME} executable..."
        chmod +x "${BINARY_DIR}/${OPA_BINARY_NAME}"
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to make existing ${OPA_BINARY_NAME} executable." >&2
            # set -e handles exit
        fi
    fi
fi


# DOWNLOAD CONFORMA CLI (EC CLI)

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

# --- Download and Prepare Binary ---
if [[ ! -f "${BINARY_DIR}/${EC_BINARY_NAME}" ]]; then
    echo "Enterprise Contract CLI (${EC_BINARY_NAME}) not found. Downloading..."
    if ! command -v curl &> /dev/null; then
        echo "Error: 'curl' command not found. Please install curl." >&2
        exit 1
    fi
    curl -sSfL "${EC_CLI_URL}" -o "${BINARY_DIR}/${EC_BINARY_NAME}"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download ${EC_BINARY_NAME}" >&2
        # set -e handles exit
    fi

    echo "Making ${EC_BINARY_NAME} executable..."
    chmod +x "${BINARY_DIR}/${EC_BINARY_NAME}"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to make ${EC_BINARY_NAME} executable." >&2
        # set -e handles exit
    fi
    echo "Download and preparation complete."
else
    echo "Enterprise Contract CLI (${EC_BINARY_NAME}) already exists. Skipping download."
    # Ensure it's executable if it already exists, in case permissions were changed
    if [[ ! -x "${BINARY_DIR}/${EC_BINARY_NAME}" ]]; then
        echo "Making existing ${EC_BINARY_NAME} executable..."
        chmod +x "${BINARY_DIR}/${EC_BINARY_NAME}"
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to make existing ${EC_BINARY_NAME} executable." >&2
            # set -e handles exit
        fi
    fi
fi


