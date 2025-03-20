package mequal.leveling.L1.spdx.LPOL2_test

import data.ec.lib
import data.ec.lib.util.assert_passes_rules
import data.ec.lib.util.assert_violates_rules
import data.mequal.leveling.L1.spdx.LPOL2
import rego.v1

_rule_spdx_sbom_all_components_contain_versions := "mequal.leveling.L1.spdx.LPOL2.spdx_sbom_all_components_contain_versions"

_rule_spdx_sbom_has_packages_field := "mequal.leveling.L1.spdx.LPOL2.spdx_sbom_has_packages_field"

_rule_spdx_sbom_packages_field_not_empty := "mequal.leveling.L1.spdx.LPOL2.spdx_sbom_packages_field_not_empty"

# Prerequisites

# If not an SPDX, make sure no rules in this policy are evaluated (i.e. don't return violations)
test_prerequisite if {
	sbom := {"name": "John", "surname": "Smith"}
	results := LPOL2.deny with input as sbom
	lib.assert_equal(count(results), 0)
}

# Versions

test_spdx_sbom_all_components_contain_versions if {
	sbom := {"SPDXID": "SPDXRef-DOCUMENT", "packages": [{"SPDXID": "test", "versionInfo": "1.3"}]}
	results := LPOL2.deny with input as sbom
	assert_passes_rules(results, [_rule_spdx_sbom_all_components_contain_versions])
}

test_spdx_sbom_a_component_does_not_have_version if {
	sbom := {"SPDXID": "SPDXRef-DOCUMENT", "packages": [{"SPDXID": "test"}]}
	results := LPOL2.deny with input as sbom
	assert_violates_rules(results, [_rule_spdx_sbom_all_components_contain_versions])
}

# Packages

test_spdx_sbom_has_packages_field if {
	sbom := {"SPDXID": "SPDXRef-DOCUMENT", "packages": [{"SPDXID": "test", "versionInfo": "1.3"}]}
	results := LPOL2.deny with input as sbom
	assert_passes_rules(results, [_rule_spdx_sbom_has_packages_field])
}

test_spdx_sbom_does_not_have_packages_field if {
	sbom := {"SPDXID": "SPDXRef-DOCUMENT"}
	results := LPOL2.deny with input as sbom
	assert_violates_rules(results, [_rule_spdx_sbom_has_packages_field])
}

test_spdx_sbom_has_nonempty_packages_field if {
	sbom := {"SPDXID": "SPDXRef-DOCUMENT", "packages": [{"SPDXID": "test", "versionInfo": "1.3"}]}
	results := LPOL2.deny with input as sbom
	assert_passes_rules(results, [_rule_spdx_sbom_packages_field_not_empty])
}

test_spdx_sbom_has_empty_packages_field if {
	sbom := {"SPDXID": "SPDXRef-DOCUMENT", "packages": []}
	results := LPOL2.deny with input as sbom
	assert_violates_rules(results, [_rule_spdx_sbom_packages_field_not_empty])
}
