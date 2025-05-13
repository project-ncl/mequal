#!/bin/bash

# Download OPA and EC CLI Binaries
echo "Downloading OPA and EC CLI binaries to ./binaries/ ..."
bash ./scripts/download-binaries.sh

# Run the annotations generation script
echo "Running ./scripts/annotations-generate.sh..."
if [ -f "./scripts/annotations-generate.sh" ]; then
  bash ./scripts/annotations-generate.sh
else
  echo "Error: ./scripts/annotations-generate.sh not found."
  exit 1
fi
echo "Finished running ./scripts/annotations-generate.sh."

# Run the Python script to generate bundle info
echo "Running ./scripts/generate_bundle_info.py..."
if [ -f "./scripts/generate_bundle_info.py" ]; then
    ./scripts/generate_bundle_info.py
else
  echo "Error: ./scripts/generate_bundle_info.py not found."
  exit 1
fi
echo "Finished running ./scripts/generate_bundle_info.py."

# Run the script to download external bundles
echo "Running ./scripts/download-external-bundles.sh..."
if [ -f "./scripts/download-external-bundles.sh" ]; then
  bash ./scripts/download-external-bundles.sh
else
  echo "Error: ./scripts/download-external-bundles.sh not found."
  exit 1
fi
echo "Finished running ./scripts/download-external-bundles.sh."

echo "Dev setup script completed."