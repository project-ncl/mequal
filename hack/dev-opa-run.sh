#!/bin/bash
set -x

REGO_BUNDLE_PATH=./bundle/bundle.tar.gz
WASM_BUNDLE_PATH=./bundle/wasm_bundle.tar.gz
POLICY_PATH=./policy
OPA_CLI="./binaries/opa-cli" # The name for the downloaded binary

bash ./scripts/download-binaries.sh

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