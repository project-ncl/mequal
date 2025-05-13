#!/bin/bash

# REMOVES ALL EXTERNAL POLICIES THAT WERE TEMPORARILY DOWNLOADED FOR LOCAL DEVELOPMENT
# REMOVES ALL GENERATED METADATA-RELATED OBJECTS TEMPORARILY NEEDED FOR LOCAL DEVELOPMENT
# DOES NOT REMOVE OPA AND CONFORMA (EC) BINARIES

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the main policy directory
POLICY_DIR="./policy"
# Define the specific data file to remove
DATA_FILE_TO_REMOVE="${POLICY_DIR}/main/main/data/data.json"
# Define the annotations directory to remove
ANNOTATIONS_DIR="./policy_annotations"

echo "Starting development cleanup script..."
echo "--------------------------------------"

# --- Section 1: Remove folders in ./policy/ other than 'mequal' and 'main' ---
echo
echo "Phase 1: Cleaning up subdirectories in '${POLICY_DIR}'..."
if [ -d "${POLICY_DIR}" ]; then
    echo "The following actions will be taken for directories within '${POLICY_DIR}' (excluding 'mequal' and 'main'):"
    
    found_other_dirs_to_remove=0
    processed_dirs=0
    for item in "${POLICY_DIR}"/*; do
        if [ -d "${item}" ]; then # Check if it's a directory
            dir_name=$(basename "${item}")
            if [[ "${dir_name}" != "mequal" && "${dir_name}" != "main" ]]; then
                echo "  Removing directory: ${item}"
                rm -rf "${item}"
                found_other_dirs_to_remove=1
            else
                echo "  Skipping directory: ${item}"
            fi
            processed_dirs=1
        fi
    done

    if [ ${processed_dirs} -eq 0 ]; then
        echo "  No directories found in '${POLICY_DIR}'."
    elif [ ${found_other_dirs_to_remove} -eq 0 ] && [ ${processed_dirs} -gt 0 ]; then
        echo "  No other directories to remove were found besides 'mequal' and 'main' (or they were already removed)."
    fi
    echo "Subdirectory cleanup in '${POLICY_DIR}' complete."
else
    echo "Warning: Directory '${POLICY_DIR}' not found. Skipping subdirectory cleanup in Phase 1."
fi

# --- Section 2: Remove ./policy/main/main/data/data.json file ---
echo
echo "Phase 2: Removing specific file '${DATA_FILE_TO_REMOVE}'..."
if [ -f "${DATA_FILE_TO_REMOVE}" ]; then
    rm -f "${DATA_FILE_TO_REMOVE}"
    echo "  Successfully removed '${DATA_FILE_TO_REMOVE}'."
else
    echo "  File '${DATA_FILE_TO_REMOVE}' not found. Nothing to remove."
fi

# --- Section 3: Remove ./policy_annotations/ folder ---
echo
echo "Phase 3: Removing directory '${ANNOTATIONS_DIR}' and its contents..."
if [ -d "${ANNOTATIONS_DIR}" ]; then
    rm -rf "${ANNOTATIONS_DIR}"
    echo "  Successfully removed directory '${ANNOTATIONS_DIR}'."
else
    echo "  Directory '${ANNOTATIONS_DIR}' not found. Nothing to remove."
fi

echo "--------------------------------------"
echo "Development cleanup finished."

exit 0