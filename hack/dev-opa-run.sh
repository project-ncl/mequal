#!/bin/bash
set -x

REGO_BUNDLE_PATH=./bundle/bundle.tar.gz
WASM_BUNDLE_PATH=./bundle/wasm_bundle.tar.gz
POLICY_PATH=./policy
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
if [[ ! -f "./${OPA_BINARY_NAME}" ]]; then
    echo "OPA CLI (${OPA_BINARY_NAME}) not found. Downloading..."
    if ! command -v curl &> /dev/null; then
        echo "Error: 'curl' command not found. Please install curl." >&2
        exit 1
    fi
    curl -sSfL "${OPA_URL}" -o "${OPA_BINARY_NAME}"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download ${OPA_BINARY_NAME}" >&2
        # set -e handles exit
    fi

    echo "Making ${OPA_BINARY_NAME} executable..."
    chmod +x "./${OPA_BINARY_NAME}"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to make ${OPA_BINARY_NAME} executable." >&2
        # set -e handles exit
    fi
    echo "Download and preparation complete."
else
    echo "OPA CLI (${OPA_BINARY_NAME}) already exists. Skipping download."
    # Ensure it's executable if it already exists, in case permissions were changed
    if [[ ! -x "./${OPA_BINARY_NAME}" ]]; then
        echo "Making existing ${OPA_BINARY_NAME} executable..."
        chmod +x "./${OPA_BINARY_NAME}"
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to make existing ${OPA_BINARY_NAME} executable." >&2
            # set -e handles exit
        fi
    fi
fi

OPA_CLI="./${OPA_BINARY_NAME}"

#Print version info
${OPA_CLI} version

# TODO revisit the commands below to make them compatible with the bundle structure we adopted later on 

#Check policies for issues
# ${OPA} check -b $POLICY_PATH

#Build policies
# ${OPA} build -b $POLICY_PATH -o $REGO_BUNDLE_PATH

#Run the unit tests
# ${OPA} test -b $REGO_BUNDLE_PATH -r "data.*" -v --var-values

#Build with WASM binary in bundle
# ${OPA} build -b $POLICY_PATH -o $WASM_BUNDLE_PATH -t wasm -e "mequal" 

#Run the unit tests
# ${OPA} test -b $WASM_BUNDLE_PATH -r "data.*" -v --var-values

#Evalulate policies against this file
# ${OPA} eval --bundle $WASM_BUNDLE_PATH --input ./sbom.json -f json "data.mequal.main"