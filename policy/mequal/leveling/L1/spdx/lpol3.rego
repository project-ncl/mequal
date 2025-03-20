# METADATA
# title: LPOL3 - Level 1
# description: >-
#   Check if all packages in the CycloneDX SBOM include checksums
package mequal.leveling.L1.spdx.LPOL3

import data.ec.lib
import data.ec.lib.util.is_spdx
import rego.v1

# METADATA
# title: SPDX SBOM all components have checksums field
# description: The SPDX SBOM components all have checksums field.
# custom:
#   short_name: spdx_sbom_all_components_contain_checksums_field
#   failure_msg: SPDX SBOM component "checksums" field does not exist for SPDX ID '%s'
deny contains result if {
	is_spdx
	some i
	pck := input.packages[i]
	not pck.checksums
	result := object.union(
		lib.result_helper(rego.metadata.chain(), [pck.SPDXID]),
		{"policy_level": "L1", "policy_id": "LPOL3"},
	)
}

# METADATA
# title: SPDX SBOM all components have checksums values
# description: The SPDX SBOM components all have checksums values. Only checks flat list
# custom:
#   short_name: spdx_sbom_all_components_contain_checksums_values
#   failure_msg: SPDX SBOM component "checksums" field is empty for SPDX ID '%s'
deny contains result if {
	is_spdx
	some i
	pck := input.packages[i]
	count(pck.checksums) == 0
	result := object.union(
		lib.result_helper(rego.metadata.chain(), [pck.SPDXID]),
		{"policy_level": "L1", "policy_id": "LPOL3"},
	)
}
