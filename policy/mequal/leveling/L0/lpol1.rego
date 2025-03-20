# METADATA
# title: LPOL1 - Level 0
# description: >-
#   SBOM Level grading policy 1. Check if an SBOM is in either SPDX or CycloneDX format
package mequal.leveling.L0.LPOL1

import data.ec.lib
import data.ec.lib.util.is_cdx
import data.ec.lib.util.is_spdx
import rego.v1

# METADATA
# title: SBOM is SPDX or CycloneDX
# description: Check if the SBOM is either SPDX or CycloneDX
# custom:
#   short_name: sbom_is_spdx_or_cdx
#   failure_msg: Input is neither a CycloneDX SBOM nor a SPDX SBOM
deny contains result if {
	not is_spdx
	not is_cdx
	result := object.union(
		lib.result_helper(rego.metadata.chain(), []),
		{"policy_level": "L0", "policy_id": "LPOL1"},
	)
}
