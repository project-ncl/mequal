#!/bin/bash
set -x

OPA=${PWD}/opa
REGO_BUNDLE_PATH=./bundle/bundle.tar.gz
WASM_BUNDLE_PATH=./bundle/wasm_bundle.tar.gz
POLICY_PATH=./policy

if [ ! -f $OPA ]; then
  wget https://github.com/open-policy-agent/opa/releases/download/v1.0.0/opa_linux_amd64 -O opa
  chmod u+x $OPA
fi

#Print version info
${OPA} version

#Check policies for issues
${OPA} check -b $POLICY_PATH

#Build policies
${OPA} build -b $POLICY_PATH -o $REGO_BUNDLE_PATH

#Run the unit tests
${OPA} test -b $REGO_BUNDLE_PATH -r "data.*" -v --var-values

#Build with WASM binary in bundle
${OPA} build -b $POLICY_PATH -o $WASM_BUNDLE_PATH -t wasm -e "mequal" 

#Run the unit tests
${OPA} test -b $WASM_BUNDLE_PATH -r "data.*" -v --var-values

#Evalulate policies against this file
${OPA} eval --bundle $WASM_BUNDLE_PATH --input ./sbom.json -f json "data.mequal.main"