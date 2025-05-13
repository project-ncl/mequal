#!/bin/env bash

OUT_DIR=policy_annotations
OPA_CLI="./binaries/opa-cli"

mkdir $OUT_DIR

shopt -s nullglob

for dir in ./policy/*/ ; do
  if [[ -d "$dir" ]]; then
    # Extract the directory name for the output file
    dirname=$(basename "$dir")
    outfile="$OUT_DIR/inspection_${dirname}.json"

    echo "Inspecting annotations for: $dir and saving to $outfile"
    $OPA_CLI inspect -f json -a "$dir" > "$outfile"
    echo "---"
  fi
done

shopt -u nullglob
