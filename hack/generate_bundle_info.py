# Generated with assistance from a large language model trained by Google.

import json
import os
import sys # Import sys to handle potential exit on errors

def process_opa_json(file_path):
    """Processes a single OPA inspection JSON file and returns the bundle object."""
    data = None
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"Warning: File not found at {file_path}. Skipping.")
        return None
    except json.JSONDecodeError:
        print(f"Warning: Could not decode JSON from {file_path}. Skipping.")
        return None
    except Exception as e:
        print(f"Warning: An unexpected error occurred reading {file_path}: {e}. Skipping.")
        return None

    if not data:
        return None

    # --- Start of processing logic for one file ---
    manifest = data.get('manifest', {})
    roots_list = manifest.get('roots', [])
    bundle_id = roots_list[0] if roots_list else None
    bundle_version = manifest.get('revision')
    bundle_source = manifest.get('metadata', {}).get('source')

    output_data = {
        "bundle_id": bundle_id,
        "bundle_version": bundle_version,
        **({"source": bundle_source} if bundle_source is not None else {}),
        "policies": [] # Initialize policies list
    }

    policy_map = {} # Maps tuple(package_path) -> policy_entry for rule association

    # First pass: Identify policies
    annotations_list = data.get('annotations', []) # Get annotations safely
    if not isinstance(annotations_list, list): # Ensure it's a list
        print(f"Warning: 'annotations' field is not a list in {file_path}. Skipping policy/rule processing for this file.")
        annotations_list = [] # Treat as empty if not a list

    for annotation in annotations_list:
        # Basic check for annotation structure
        if not isinstance(annotation, dict): continue
        ann_details = annotation.get('annotations', {})
        if not isinstance(ann_details, dict): continue

        ann_scope = ann_details.get('scope')

        if ann_scope == 'package':
            # Extract details from the annotation object
            custom_details = ann_details.get('custom', {}) # Safely get custom details
            policy_id = custom_details.get('short_name') if isinstance(custom_details, dict) else None
            policy_title = ann_details.get('title')
            policy_description = ann_details.get('description')
            # policy_location = annotation.get('location', {}).get('file') # --- REMOVED THIS LINE ---

            # Extract policy_severity from custom.severity, defaulting to "undefined"
            policy_severity = "Undefined" # Default value
            if isinstance(custom_details, dict): # Check if custom_details is a dictionary first
                 policy_severity = custom_details.get('severity', 'Undefined') # Use .get() with default

            # Generate policy_path from the path array
            path_list = annotation.get('path', [])
            policy_path_str = None
            package_path_tuple = tuple() # Keep tuple for rule mapping
            if isinstance(path_list, list):
                path_values = [item.get('value') for item in path_list if isinstance(item, dict) and 'value' in item]
                if path_values: # Only join if we have values
                    policy_path_str = '.'.join(map(str, path_values)) # Join values as strings
                    package_path_tuple = tuple(path_values) # Use the same values for the tuple key

            # Check if essential fields were found (adjust as needed)
            if policy_id and policy_title:
                policy_entry = {
                    "policy_id": policy_id,
                    "policy_title": policy_title,
                    "policy_description": policy_description,
                    "policy_severity": policy_severity,
                    # "policy_location": policy_location, # --- REMOVED THIS LINE ---
                    "policy_path": policy_path_str,
                    "rules": []
                }
                # Append the identified policy
                output_data["policies"].append(policy_entry)
                # Use the path tuple for rule mapping
                if package_path_tuple:
                    policy_map[package_path_tuple] = policy_entry


    # Second pass: Identify rules and map them (only if policies were found/processed)
    if output_data["policies"]: # Optimization: only look for rules if policies exist
        for annotation in annotations_list: # Use the safe annotations_list
             # Basic check for annotation structure
            if not isinstance(annotation, dict): continue
            ann_details = annotation.get('annotations', {})
            if not isinstance(ann_details, dict): continue

            ann_scope = ann_details.get('scope')

            if ann_scope == 'rule':
                custom_annotations = ann_details.get('custom', {})
                if not isinstance(custom_annotations, dict): continue # Ensure custom is a dict

                rule_id = custom_annotations.get('short_name')
                rule_title = ann_details.get('title')
                rule_description = ann_details.get('description')
                rule_path = annotation.get('path', [])

                if rule_id and rule_title and rule_description and isinstance(rule_path, list) and len(rule_path) > 0:
                     # Determine the package path tuple for mapping
                     package_path_tuple = tuple(item.get('value') for item in rule_path[:-1] if isinstance(item, dict) and 'value' in item)
                     # Find the corresponding policy using the tuple key
                     if package_path_tuple in policy_map:
                         policy_map[package_path_tuple]['rules'].append({
                             "rule_id": rule_id,
                             "rule_title": rule_title,
                             "rule_description": rule_description
                         })

    # --- End of processing logic for one file ---
    return output_data

# --- Main script execution ---

# !!! IMPORTANT: Set this to the directory containing your JSON files !!!
target_directory = 'policy_annotations' # Example path - CHANGE THIS

# Check if the target directory exists
if not os.path.isdir(target_directory):
    print(f"Error: Directory not found: {target_directory}")
    sys.exit(1) # Exit if directory doesn't exist

all_bundles = []

print(f"Processing JSON files in directory: {target_directory}")

# Iterate through all files in the specified directory
for filename in os.listdir(target_directory):
    # Check if the file is a JSON file
    if filename.lower().endswith('.json'):
        file_path = os.path.join(target_directory, filename)
        print(f"--> Processing file: {filename}")
        # Process the file using the function defined above
        bundle_object = process_opa_json(file_path)

        # Check if processing was successful AND if the 'policies' list is not empty
        if bundle_object and bundle_object.get("policies"):
            all_bundles.append(bundle_object)
            print(f"    Added bundle from {filename} (Policies found: {len(bundle_object['policies'])})")
        elif bundle_object: # If bundle_object exists but has no policies
            print(f"    Skipped bundle from {filename} (No policies found or missing required policy fields)")
        else: # If bundle_object is None (due to read errors etc.)
             print(f"   Skipped file {filename} due to errors during processing.")


# Create the final output structure
final_output = {"bundles": all_bundles}

# Convert the final structure to a JSON string
final_output_json_str = json.dumps(final_output, indent=2)

# Define output directory
output_directory = './bundle'

if not os.path.exists(output_directory):
    os.makedirs(output_directory)

# Define the output filename
output_filename = output_directory + '/bundle_metadata.json' # Keeping filename same as last version

# Save the combined data to the output file
try:
    with open(output_filename, 'w') as outfile:
        outfile.write(final_output_json_str)
    print(f"\nSuccessfully processed and included {len(all_bundles)} bundle(s) with policies.")
    print(f"Combined results saved to: {output_filename}")
except Exception as e:
    print(f"\nError writing final output file {output_filename}: {e}")