package mequal.leveling.L1.cyclonedx.LPOL3_test

import data.ec.lib
import data.ec.lib.util.assert_passes_rules
import data.ec.lib.util.assert_violates_rules
import data.mequal.leveling.L1.cyclonedx.LPOL3
import rego.v1

_rule_cdx_sbom_all_components_contain_hashes_field := "mequal.leveling.L1.cyclonedx.LPOL3.cdx_sbom_all_components_contain_hashes_field"

_rule_cdx_sbom_all_components_contain_hash_values := "mequal.leveling.L1.cyclonedx.LPOL3.cdx_sbom_all_components_contain_hash_values"

# Prerequisites

# If not a CycloneDX, make sure no rules in this policy are evaluated (i.e. don't return violations)
# Given an SBOM that doesn't fulfil the prerequisites of this policy, no evaluation should occur
test_prerequisite if {
	sbom := {"name": "John", "surname": "Smith"}
	results := LPOL3.deny with input as sbom
	lib.assert_equal(count(results), 0)
}

# Hashes

test_cdx_sbom_all_components_contain_hashes if {
	sbom := {"bomFormat": "CycloneDX", "components": [{"bom-ref": "test", "hashes": [{"test": "test"}]}]}
	results := LPOL3.deny with input as sbom
	assert_passes_rules(results, [
		_rule_cdx_sbom_all_components_contain_hashes_field,
		_rule_cdx_sbom_all_components_contain_hash_values,
	])
}

test_cdx_sbom_a_component_does_not_contain_hash_field if {
	sbom := {"bomFormat": "CycloneDX", "components": [{"bom-ref": "test"}]}
	results := LPOL3.deny with input as sbom
	assert_violates_rules(results, [_rule_cdx_sbom_all_components_contain_hashes_field])
}

test_cdx_sbom_a_component_does_not_contain_hash_values if {
	sbom := {"bomFormat": "CycloneDX", "components": [{"bom-ref": "test", "hashes": []}]}
	results := LPOL3.deny with input as sbom
	assert_violates_rules(results, [_rule_cdx_sbom_all_components_contain_hash_values])
}

test_cdx_sbom_a_component_does_not_contain_hash_field_nested if {
	sbom := {
		"bomFormat": "CycloneDX",
		"components": [{
			"bom-ref": "test",
			"hashes": [{"test": "test"}],
			"components": [{"bom-ref": "test", "name": "test"}],
		}],
	}
	results := LPOL3.deny with input as sbom
	assert_violates_rules(results, [_rule_cdx_sbom_all_components_contain_hashes_field])
}

test_cdx_sbom_a_component_does_not_contain_hash_values_nested if {
	sbom := {
		"bomFormat": "CycloneDX",
		"components": [{
			"bom-ref": "test",
			"hashes": [{"test": "test"}],
			"components": [{"bom-ref": "test", "hashes": []}],
		}],
	}
	results := LPOL3.deny with input as sbom
	assert_violates_rules(results, [_rule_cdx_sbom_all_components_contain_hash_values])
}
