package mequal.leveling.L1.cyclonedx.LPOL2_test

import data.ec.lib
import data.ec.lib.util.assert_passes_rules
import data.ec.lib.util.assert_violates_rules
import data.mequal.leveling.L1.cyclonedx.LPOL2
import rego.v1

_rule_cdx_sbom_has_no_components_field := "mequal.leveling.L1.cyclonedx.LPOL2.cdx_sbom_has_no_components_field"

_rule_cdx_sbom_has_empty_components_field := "mequal.leveling.L1.cyclonedx.LPOL2.cdx_sbom_has_empty_components_field"

_rule_cdx_sbom_all_components_contain_versions := "mequal.leveling.L1.cyclonedx.LPOL2.cdx_sbom_all_components_contain_versions"

_rule_cdx_sbom_has_top_component_version := "mequal.leveling.L1.cyclonedx.LPOL2.cdx_sbom_has_top_component_version"

_rule_cdx_sbom_all_components_have_bomref_field := "mequal.leveling.L1.cyclonedx.LPOL2.cdx_sbom_all_components_have_bomref_field"

_rule_cdx_sbom_all_components_have_valid_bomref_value := "mequal.leveling.L1.cyclonedx.LPOL2.cdx_sbom_all_components_have_valid_bomref_value"

# Prerequisites

# If not a CycloneDX, make sure no rules in this policy are evaluated (i.e. don't return violations)
# Given an SBOM that doesn't fulfil the prerequisites of this policy, no evaluation should occur
test_prerequisite if {
	sbom := {"name": "John", "surname": "Smith"}
	results := LPOL2.deny with input as sbom
	lib.assert_equal(count(results), 0)
}

# Components

test_cdx_sbom_has_components if {
	sbom := {"bomFormat": "CycloneDX", "components": [{"bom-ref": "test"}]}
	results := LPOL2.deny with input as sbom
	assert_passes_rules(results, [
		_rule_cdx_sbom_has_no_components_field,
		_rule_cdx_sbom_has_empty_components_field,
	])
}

test_cdx_sbom_has_no_components_field if {
	sbom := {"bomFormat": "CycloneDX"}
	results := LPOL2.deny with input as sbom
	assert_violates_rules(results, [_rule_cdx_sbom_has_no_components_field])
}

test_cdx_sbom_has_empty_components_field if {
	sbom := {"bomFormat": "CycloneDX", "components": []}
	results := LPOL2.deny with input as sbom
	assert_violates_rules(results, [_rule_cdx_sbom_has_empty_components_field])
}

# Versions

test_cdx_sbom_all_components_including_metadata_contain_versions if {
	sbom := {
		"bomFormat": "CycloneDX",
		"metadata": {"component": {"name": "test", "version": "1.5"}},
		"components": [
			{"bom-ref": "test1", "version": "1.2"},
			{"bom-ref": "test2", "version": "1.3"},
		],
	}
	results := LPOL2.deny with input as sbom
	assert_passes_rules(results, [
		_rule_cdx_sbom_all_components_contain_versions,
		_rule_cdx_sbom_has_top_component_version,
	])
}

test_cdx_sbom_all_components_contain_versions_missing_top_version if {
	sbom := {
		"bomFormat": "CycloneDX",
		"metadata": {"component": {"name": "test"}},
		"components": [
			{"bom-ref": "test1", "version": "1.2"},
			{"bom-ref": "test2", "version": "1.3"},
		],
	}
	results := LPOL2.deny with input as sbom
	assert_violates_rules(results, [_rule_cdx_sbom_has_top_component_version])
}

test_cdx_sbom_all_components_contain_versions_missing_version_in_components if {
	sbom := {
		"bomFormat": "CycloneDX",
		"metadata": {"component": {"name": "test"}},
		"components": [
			{"bom-ref": "test1", "version": "1.2"},
			{"bom-ref": "test2"},
		],
	}
	results := LPOL2.deny with input as sbom
	assert_violates_rules(results, [_rule_cdx_sbom_all_components_contain_versions])
}

test_cdx_sbom_all_components_contain_versions_missing_version_in_nested_component if {
	sbom := {
		"bomFormat": "CycloneDX",
		"metadata": {"component": {"name": "test", "version": "1.0"}},
		"components": [{"bom-ref": "test1", "version": "1.2", "components": [{"bom-ref": "test2"}]}],
	}
	results := LPOL2.deny with input as sbom
	assert_violates_rules(results, [_rule_cdx_sbom_all_components_contain_versions])
}

# Bom-refs

test_cdx_sbom_all_components_have_valid_bomref if {
	sbom := {"bomFormat": "CycloneDX", "components": [{"bom-ref": "test"}]}
	results := LPOL2.deny with input as sbom
	assert_passes_rules(results, [
		_rule_cdx_sbom_all_components_have_bomref_field,
		_rule_cdx_sbom_all_components_have_valid_bomref_value,
	])
}

# needs a purl to identify missing bom-ref field
test_cdx_sbom_a_component_does_not_have_bomref_field if {
	sbom := {"bomFormat": "CycloneDX", "components": [{"name": "test", "purl": "testpurl"}]}
	results := LPOL2.deny with input as sbom
	assert_violates_rules(results, [_rule_cdx_sbom_all_components_have_bomref_field])
}

test_cdx_sbom_a_component_has_invalid_bomref_value if {
	sbom := {"bomFormat": "CycloneDX", "components": [{"bom-ref": "urn:cdx:test"}]}
	results := LPOL2.deny with input as sbom
	assert_violates_rules(results, [_rule_cdx_sbom_all_components_have_valid_bomref_value])
}

# needs a purl to identify missing bom-ref field
test_cdx_sbom_a_component_does_not_have_bomref_field_nested if {
	sbom := {"bomFormat": "CycloneDX", "components": [{"bom-ref": "test", "components": [{"name": "test", "purl": "testpurl"}]}]}
	results := LPOL2.deny with input as sbom
	assert_violates_rules(results, [_rule_cdx_sbom_all_components_have_bomref_field])
}

test_cdx_sbom_a_component_has_invalid_bomref_value_nested if {
	sbom := {"bomFormat": "CycloneDX", "components": [{"bom-ref": "test", "components": [{"bom-ref": "urn:cdx:test"}]}]}
	results := LPOL2.deny with input as sbom
	assert_violates_rules(results, [_rule_cdx_sbom_all_components_have_valid_bomref_value])
}
