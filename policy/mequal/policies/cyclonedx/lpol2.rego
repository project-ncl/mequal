# METADATA
# title: SBOMs include a version and a bom-ref, has components
# description: >-
#   SBOM Level grading policy 2. Check if all packages in the SBOM include a version and a bom-ref, and has components
# custom:
#   short_name: LPOL2
#   severity: error
#   level: L1
package mequal.policies.cyclonedx.LPOL2

import data.ec.lib
import data.ec.lib.util.is_cdx
import data.ec.lib.util.reverse_index
import rego.v1

# Define the prerequisites to check for each policy (i.e. what SBOMs should these policies run on?)
prerequisite if {
	is_cdx
}

# METADATA
# title: CDX SBOM has Components
# description: The CycloneDX SBOM contains components
# custom:
#   short_name: cdx_sbom_has_empty_components_field
#   failure_msg: CycloneDX SBOM contains no components
#   severity: error
#   level: L1
deny contains result if {
	prerequisite
	count(input.components) < 1
	result := object.union(
		lib.result_helper(rego.metadata.chain(), []),
		{"extra": {}},
	)
}

# METADATA
# title: CDX SBOM has Components
# description: The CycloneDX SBOM contains components
# custom:
#   short_name: cdx_sbom_has_no_components_field
#   failure_msg: CycloneDX SBOM contains no components
#   severity: error
#   level: L1
deny contains result if {
	prerequisite
	not input.components
	result := object.union(
		lib.result_helper(rego.metadata.chain(), []),
		{"extra": {}},
	)
}

# METADATA
# title: CDX SBOM top component has version
# description: The CycloneDX SBOM top component contains a version field
# custom:
#   short_name: cdx_sbom_has_top_component_version
#   failure_msg: CycloneDX SBOM top component (.metadata.component) does NOT contain version
#   severity: error
#   level: L1
deny contains result if {
	prerequisite
	not input.metadata.component.version
	result := object.union(
		lib.result_helper(rego.metadata.chain(), []),
		{"policy_level": "L1", "policy_id": "LPOL2"},
	)
}

# METADATA
# title: CDX SBOM Components all have versions
# description: The CycloneDX SBOM components all have versions. Checks all components including nested ones.
# custom:
#   short_name: cdx_sbom_all_components_contain_versions
#   failure_msg: CycloneDX SBOM component version missing for bom-ref '%s'
#   severity: error
#   level: L1
deny contains result if {
	prerequisite
	some path, value
	walk(input.components, [path, value])
	is_number(reverse_index(path, 1))
	value["bom-ref"]
	not value.version
	result := object.union(
		lib.result_helper(rego.metadata.chain(), [value["bom-ref"]]),
		{"extra": {}},
	)
}

# METADATA
# title: CDX SBOM Components all have bom-ref field
# description: The CycloneDX SBOM components all have bom-ref fields. Checks all components including nested ones.
# custom:
#   short_name: cdx_sbom_all_components_have_bomref_field
#   failure_msg: CycloneDX SBOM component bom-ref is missing for purl '%s'
#   severity: error
#   level: L1
deny contains result if {
	prerequisite
	some path, value
	walk(input.components, [path, value])
	is_number(reverse_index(path, 1))

	# not the best solution, assumes purl would exist if bom-ref isn't there
	not value["bom-ref"]
	value.purl
	result := object.union(
		lib.result_helper(rego.metadata.chain(), [value.purl]),
		{"extra": {}},
	)
}

# METADATA
# title: CDX SBOM Components all have VALID bom-ref values
# description: The CycloneDX SBOM components all have valid bom-ref values. Checks all components including nested ones.
# custom:
#   short_name: cdx_sbom_all_components_have_valid_bomref_value
#   failure_msg: CycloneDX SBOM component bom-ref is invalid
#   severity: error
#   level: L1
deny contains result if {
	prerequisite
	some path, value
	walk(input.components, [path, value])
	is_number(reverse_index(path, 1))
	bomref_is_invalid(value["bom-ref"])
	result := object.union(
		lib.result_helper(rego.metadata.chain(), []),
		{"extra": {}},
	)
}

bomref_is_invalid(bom_ref) if {
	startswith(bom_ref, "urn:cdx:")
}
