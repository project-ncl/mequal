package ec.lib.util_test

import data.ec.lib
import data.ec.lib.util
import rego.v1

test_sbom_is_cdx if {
	sbom := {"bomFormat": "CycloneDX"}
	util.is_cdx with input as sbom
}

test_sbom_is_spdx if {
	sbom := {"SPDXID": "SPDXRef-DOCUMENT"}
	util.is_spdx with input as sbom
}

test_input_is_random_json if {
	sbom := {"name": "Jack"}
	not util.is_cdx with input as sbom
	not util.is_spdx with input as sbom
}

test_input_is_empty if {
	sbom := ""
	not util.is_cdx with input as sbom
	not util.is_spdx with input as sbom
}

test_input_is_nonesense if {
	sbom := "21eqwe2"
	not util.is_cdx with input as sbom
	not util.is_spdx with input as sbom
}
