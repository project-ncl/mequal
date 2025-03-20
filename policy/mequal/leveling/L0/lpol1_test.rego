package mequal.leveling.L0.LPOL1_test

import data.ec.lib
import data.ec.lib.util.assert_passes_rules
import data.ec.lib.util.assert_violates_rules
import data.mequal.leveling.L0.LPOL1
import rego.v1

_rule_sbom_is_spdx_or_cdx := "mequal.leveling.L0.LPOL1.sbom_is_spdx_or_cdx"

test_sbom_is_cdx if {
	sbom := {"bomFormat": "CycloneDX"}
	results := LPOL1.deny with input as sbom
	assert_passes_rules(results, [_rule_sbom_is_spdx_or_cdx])
}

test_sbom_is_spdx if {
	sbom := {"SPDXID": "SPDXRef-DOCUMENT"}
	results := LPOL1.deny with input as sbom
	assert_passes_rules(results, [_rule_sbom_is_spdx_or_cdx])
}

test_sbom_is_none if {
	sbom := {"name": "John", "surname": "Smith"}
	results := LPOL1.deny with input as sbom
	assert_violates_rules(results, [_rule_sbom_is_spdx_or_cdx])
}

test_empty_input if {
	sbom := ""
	results := LPOL1.deny with input as sbom
	assert_violates_rules(results, [_rule_sbom_is_spdx_or_cdx])
}

test_empty_json if {
	sbom := {}
	results := LPOL1.deny with input as sbom
	assert_violates_rules(results, [_rule_sbom_is_spdx_or_cdx])
}

test_nonsense if {
	sbom := "123%%nonsense\n123"
	results := LPOL1.deny with input as sbom
	assert_violates_rules(results, [_rule_sbom_is_spdx_or_cdx])
}
