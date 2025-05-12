# METADATA
# title: All packages in the SBOM include a version
# description: >-
#   Check if all packages in the SBOM include a version
# custom:
#   short_name: LPOL2
#   severity: error
#   level: L1
package mequal.policies.spdx.LPOL2

import data.ec.lib
import data.ec.lib.util.is_spdx
import rego.v1

# Define the prerequisites to check for each policy (i.e. what SBOMs should these policies run on?)
prerequisite if {
	is_spdx
}

# METADATA
# title: SPDX SBOM has a packages field
# description: The SPDX SBOM has a packages field.
# custom:
#   short_name: spdx_sbom_has_packages_field
#   failure_msg: SPDX SBOM does not have a packages field
#   severity: error
#   level: L1
deny contains result if {
	prerequisite
	not input.packages
	result := object.union(
		lib.result_helper(rego.metadata.chain(), []),
		{"extra": {}},
	)
}

# METADATA
# title: SPDX SBOM packages field not empty
# description: The SPDX SBOM has a non-empty packages field.
# custom:
#   short_name: spdx_sbom_packages_field_not_empty
#   failure_msg: SPDX SBOM does not have a packages field
#   severity: error
#   level: L1
deny contains result if {
	prerequisite
	count(input.packages) == 0
	result := object.union(
		lib.result_helper(rego.metadata.chain(), []),
		{"extra": {}},
	)
}

# METADATA
# title: SPDX SBOM Components all have versions
# description: The SPDX SBOM components all have versions.
# custom:
#   short_name: spdx_sbom_all_components_contain_versions
#   failure_msg: SPDX SBOM component does not have versionInfo for SPDX ID '%s'
#   severity: error
#   level: L1
deny contains result if {
	prerequisite
	some i
	pck = input.packages[i]
	not pck.versionInfo
	result := object.union(
		lib.result_helper(rego.metadata.chain(), [pck.SPDXID]),
		{"extra": {}},
	)
}
