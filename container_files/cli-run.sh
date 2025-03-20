#!/bin/bash

# echo "Loading SBOM input..."
timeout --foreground 5 cat - >> ./input.json
if [ ! -s "./input.json" ]; then
    echo "Error: No input provided for evaluation."
    echo "Please pass input as STDIN (e.g. cat sbom.json | podman run -i <image>)"
    exit 1
fi

OPA=${PWD}/opa
BUNDLE_PATH=./bundle/mequal_policies.tar.gz
POLICY_PATH=./policy

#Evalulate policies against this file
output=`${OPA} eval --bundle $BUNDLE_PATH --input ./input.json -f json "data.mequal.main"`

echo $output | jq '[.result[0].expressions[].value] | add'