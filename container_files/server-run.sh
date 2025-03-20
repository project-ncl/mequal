#!/bin/bash

OPA=${PWD}/opa
BUNDLE_PATH=./bundle/mequal_policies.tar.gz
POLICY_PATH=./policy

# Start OPA server with Mequal policies
exec ${OPA} run -s -b ./bundle/mequal_policies.tar.gz -a 0.0.0.0:8181