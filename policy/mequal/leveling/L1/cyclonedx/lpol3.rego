# METADATA
# title: LPOL3 - Level 1
# description: >-
#   Check if all packages in the CycloneDX SBOM include checksums
package mequal.leveling.L1.cyclonedx.LPOL3

import rego.v1

import data.ec.lib
import data.ec.lib.util.is_cdx
import data.ec.lib.util.reverse_index

# Define the prerequisites to check for each policy (i.e. what SBOMs should these policies run on?)
prerequisite if {
	is_cdx
}

# METADATA
# title: CDX SBOM all components have hashes field
# description: The CycloneDX SBOM components all have hashes field. Checks all components including nested ones.
# custom:
#   short_name: cdx_sbom_all_components_contain_hashes_field
#   failure_msg: CycloneDX SBOM component "hashes" field is missing for bom-ref '%s'
deny contains result if {
	prerequisite
	some path, value
	walk(input.components, [path, value])
	is_number(reverse_index(path, 1))
	value["bom-ref"]
	not value.hashes
	result := object.union(
		lib.result_helper(rego.metadata.chain(), [value["bom-ref"]]),
		{"policy_level": "L1", "policy_id": "LPOL3"},
	)
}

# METADATA
# title: CDX SBOM all components have values in their hashes field
# description: The CycloneDX SBOM components all have values in their hashes field. Checks all components including nested ones.
# custom:
#   short_name: cdx_sbom_all_components_contain_hash_values
#   failure_msg: CycloneDX SBOM component "hashes" field is empty for bom-ref '%s'
deny contains result if {
	prerequisite
	some path, value
	walk(input.components, [path, value])
	is_number(reverse_index(path, 1))
	value["bom-ref"]
	count(value.hashes) == 0
	result := object.union(
		lib.result_helper(rego.metadata.chain(), [value["bom-ref"]]),
		{"policy_level": "L1", "policy_id": "LPOL3"},
	)
}
