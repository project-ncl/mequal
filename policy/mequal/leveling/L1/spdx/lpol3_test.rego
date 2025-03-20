package mequal.leveling.L1.spdx.LPOL3_test

import data.ec.lib
import data.ec.lib.util.assert_passes_rules
import data.ec.lib.util.assert_violates_rules
import data.mequal.leveling.L1.spdx.LPOL3
import rego.v1

_rule_spdx_sbom_all_components_contain_checksums_field := "mequal.leveling.L1.spdx.LPOL3.spdx_sbom_all_components_contain_checksums_field"

_rule_spdx_sbom_all_components_contain_checksums_values := "mequal.leveling.L1.spdx.LPOL3.spdx_sbom_all_components_contain_checksums_values"

# If not an SPDX, make sure no rules in this policy are evaluated (i.e. don't return violations)
test_prerequisite if {
	sbom := {"name": "John", "surname": "Smith"}
	results := LPOL3.deny with input as sbom
	lib.assert_equal(count(results), 0)
}

# Checksums

test_spdx_sbom_components_contain_checksums_field if {
	sbom := {"SPDXID": "SPDXRef-DOCUMENT", "packages": [{"SPDXID": "test", "versionInfo": "1.3", "checksums": [{"test": "test"}]}]}
	results := LPOL3.deny with input as sbom
	assert_passes_rules(results, [_rule_spdx_sbom_all_components_contain_checksums_field])
}

test_spdx_sbom_a_component_does_not_contain_checksums_field if {
	sbom := {"SPDXID": "SPDXRef-DOCUMENT", "packages": [{"SPDXID": "test", "versionInfo": "1.3"}]}
	results := LPOL3.deny with input as sbom
	assert_violates_rules(results, [_rule_spdx_sbom_all_components_contain_checksums_field])
}

test_spdx_sbom_all_components_contain_checksums_values if {
	sbom := {"SPDXID": "SPDXRef-DOCUMENT", "packages": [{"SPDXID": "test", "versionInfo": "1.3", "checksums": [{"test": "test"}]}]}
	results := LPOL3.deny with input as sbom
	assert_passes_rules(results, [_rule_spdx_sbom_all_components_contain_checksums_values])
}

test_spdx_sbom_a_component_does_not_contain_checksums_values if {
	sbom := {"SPDXID": "SPDXRef-DOCUMENT", "packages": [{"SPDXID": "test", "versionInfo": "1.3", "checksums": []}]}
	results := LPOL3.deny with input as sbom
	assert_violates_rules(results, [_rule_spdx_sbom_all_components_contain_checksums_values])
}
