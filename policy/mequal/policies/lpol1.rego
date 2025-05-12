# METADATA
# title: SBOM either SPDX or CycloneDX
# description: >-
#   SBOM Level grading policy 1. Check if an SBOM is in either SPDX or CycloneDX format
# custom:
#   short_name: LPOL1
#   level: L0
package mequal.policies.LPOL1

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
#   severity: error
#   level: L0
deny contains result if {
	not is_spdx
	not is_cdx
	result := object.union(
		lib.result_helper(rego.metadata.chain(), []),
		{"extra": {}},
	)
}
