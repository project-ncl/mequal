# Generated with assistance from a large language model trained by Google.

import json
import os

def generate_asciidoc(data):
    """
    Generates a prettier AsciiDoc documentation from the bundle metadata.
    """
    asciidoc_lines = []

    asciidoc_lines.append("= Policy Bundle Documentation")
    asciidoc_lines.append(":toc: left")
    asciidoc_lines.append(":toclevels: 4") # Increased to include H5 for rules
    asciidoc_lines.append(":sectnums:")
    asciidoc_lines.append(":source-highlighter: rouge") # Optional: for syntax highlighting if you add code blocks later
    asciidoc_lines.append("TIP: Use Ctrl+Click or Cmd+Click on Table of Contents entries to navigate.")
    asciidoc_lines.append("") # Blank line after document header attributes

    if "bundles" not in data or not isinstance(data["bundles"], list):
        asciidoc_lines.append("_No bundles found in the JSON data._")
        return "\n".join(asciidoc_lines)

    for bundle_idx, bundle in enumerate(data["bundles"]):
        bundle_id = bundle.get("bundle_id", f"Unnamed Bundle {bundle_idx+1}")
        bundle_version = bundle.get("bundle_version", "N/A")
        bundle_source = bundle.get("source")

        asciidoc_lines.append(f"== Bundle: `{bundle_id}`") # Bundle ID in backticks
        asciidoc_lines.append("")
        asciidoc_lines.append(f"*Version:* `{bundle_version}`")
        if bundle_source:
            asciidoc_lines.append(f"*Source:* link:{bundle_source}[{bundle_source}]")
        asciidoc_lines.append("") # Blank line after bundle header

        if "policies" not in bundle or not isinstance(bundle["policies"], list) or not bundle["policies"]:
            asciidoc_lines.append("_No policies found in this bundle._")
            asciidoc_lines.append("")
            continue

        for policy_idx, policy in enumerate(bundle["policies"]):
            policy_title = policy.get("policy_title", f"Untitled Policy {policy_idx+1}")
            policy_id = policy.get("policy_id", "N/A")
            policy_severity = policy.get("policy_severity", "Undefined")
            policy_level = policy.get("policy_level", "Undefined")
            policy_path = policy.get("policy_path", "N/A")
            policy_description = policy.get("policy_description", "").strip()

            asciidoc_lines.append(f"=== Policy: {policy_title} (`{policy_id}`)")
            asciidoc_lines.append("") # Blank line after policy title

            # Policy Attributes
            asciidoc_lines.append(f"*Severity:* `{policy_severity}`")
            asciidoc_lines.append(f"*Level:* `{policy_level}`")
            if policy_path != "N/A":
                asciidoc_lines.append(f"*Path:* `{policy_path}`")
            asciidoc_lines.append("") # Blank line after attributes
            
            # Policy Description
            if policy_description:
                asciidoc_lines.append(policy_description)
                asciidoc_lines.append("") 
            else:
                asciidoc_lines.append("_No description provided._")
                asciidoc_lines.append("")

            # Rules Section
            if "rules" not in policy or not isinstance(policy["rules"], list) or not policy["rules"]:
                asciidoc_lines.append("_No rules defined for this policy._")
                asciidoc_lines.append("")
            else:
                asciidoc_lines.append("==== Rules") # Sub-section for all rules of this policy
                asciidoc_lines.append("")
            
                for rule_idx, rule in enumerate(policy["rules"]):
                    rule_title = rule.get("rule_title", f"Untitled Rule {rule_idx+1}")
                    rule_id = rule.get("rule_id", "N/A")
                    rule_severity = rule.get("rule_severity", "Undefined")
                    rule_level = rule.get("rule_level", "Undefined")
                    rule_description = rule.get("rule_description", "").strip()
                    grading_level = rule.get("level") 

                    # Each rule is now its own H5 subsection
                    asciidoc_lines.append(f"===== Rule: {rule_title} (`{rule_id}`)")
                    asciidoc_lines.append("") # Blank line after rule title

                    # Rule Attributes
                    asciidoc_lines.append(f"*Severity:* `{rule_severity}`")
                    asciidoc_lines.append(f"*Level:* `{rule_level}`")
                    if grading_level: # Show grading level if present
                         asciidoc_lines.append(f"*Grading Context Level:* `{grading_level}`")
                    asciidoc_lines.append("") # Blank line after attributes

                    # Rule Description
                    if rule_description:
                        asciidoc_lines.append(rule_description)
                        asciidoc_lines.append("")
                    else:
                        asciidoc_lines.append("_No rule description provided._")
                        asciidoc_lines.append("")
            
            # Add a horizontal rule for major separation between policies
            if policy_idx < len(bundle["policies"]) - 1:
                asciidoc_lines.append("'''") # Horizontal rule
                asciidoc_lines.append("")

        # Blank line after all policies of a bundle (if there were policies)
        if bundle.get("policies"): # Check if policies list was not empty
             asciidoc_lines.append("")


    return "\n".join(asciidoc_lines)

def main():
    input_filename = './bundle/bundle_metadata.json'
    output_filename = './docs/modules/policies/pages/index.adoc'

    try:
        with open(input_filename, 'r', encoding='utf-8') as f:
            json_data = json.load(f)
    except FileNotFoundError:
        print(f"Error: Input file '{input_filename}' not found.")
        print(f"Please ensure your JSON file is located at this path.")
        return
    except json.JSONDecodeError as e:
        print(f"Error: Could not decode JSON from '{input_filename}'. Invalid JSON format: {e}")
        return
    except Exception as e:
        print(f"An unexpected error occurred while reading the input file: {e}")
        return

    asciidoc_content = generate_asciidoc(json_data)

    try:
        output_dir = os.path.dirname(output_filename)
        if output_dir: 
            os.makedirs(output_dir, exist_ok=True)

        with open(output_filename, 'w', encoding='utf-8') as f:
            f.write(asciidoc_content)
        print(f"AsciiDoc documentation generated successfully: {output_filename}")

    except Exception as e:
        print(f"An error occurred while writing the output file: {e}")

if __name__ == "__main__":
    main()