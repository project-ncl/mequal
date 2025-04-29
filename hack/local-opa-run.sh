#!/bin/bash
set -x
set -e 

OPA=${PWD}/opa
ECE=${PWD}/ece
REGAL=${PWD}/regal
REGO_BUNDLE_PATH=./bundle/bundle.tar.gz
WASM_BUNDLE_PATH=./bundle/wasm_bundle.tar.gz
POLICY_PATHS=$(ls -d -- ./policy/*/)

if [ ! -f $OPA ]; then
  wget https://github.com/open-policy-agent/opa/releases/download/v1.0.0/opa_linux_amd64 -O opa
  chmod u+x $OPA
fi

if [ ! -f $ECE ]; then
    wget https://github.com/enterprise-contract/ec-cli/releases/download/v0.6.159/ec_linux_amd64 -O ece
    chmod u+x $ECE 
fi

if [ ! -f $REGAL ]; then 
  wget https://github.com/StyraInc/regal/releases/latest/download/regal_Linux_x86_64 -O regal
  chmod +x regal
fi

if [ ! -d $(dirname "$REGO_BUNDLE_PATH") ]; then
  mkdir $(dirname "$REGO_BUNDLE_PATH")
fi

#Use EC/Conforma to fetch our prodsec
${ECE} fetch policy -s github.com/project-ncl/mequal-prodsec-policies//policy/prodsec

#Print version info
${OPA} version

#Check policies for issues
${OPA} check -b $POLICY_PATHS

#Build policies
${OPA} build -b $POLICY_PATHS -o $REGO_BUNDLE_PATH

#Run the unit tests
${OPA} test -b $REGO_BUNDLE_PATH -r "data.mequal.*;data.prodsec.*" -v --var-values

#Build with WASM binary in bundle
${OPA} build -b $POLICY_PATHS -o $WASM_BUNDLE_PATH -t wasm -e "mequal" 

#Run the unit tests
${OPA} test -b $WASM_BUNDLE_PATH -r "data.*" -v --var-values

#Evalulate policies against this file
${OPA} eval --bundle $REGO_BUNDLE_PATH --input ./sbom.json -f json "data.mequal.main;data.prodsec.main"