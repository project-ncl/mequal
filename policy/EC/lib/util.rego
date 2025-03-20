package ec.lib.util

import data.ec.lib
import rego.v1

default is_spdx := false

is_spdx if {
	input.SPDXID == "SPDXRef-DOCUMENT"
}

default is_cdx := false

is_cdx if {
	input.bomFormat == "CycloneDX"
}

# eval_results: The evaluation results for a specific package (e.g. POL1.deny)
# rules_to_verify: The "codes" of the specific rules of the package we want to verify that it does not contain violations
assert_passes_rules(eval_results, rules_to_verify) if {
	every result in eval_results {
		result.code != rules_to_verify[_]
	}
}

# eval_results: The evaluation results for a specific package (e.g. POL1.deny)
# rules_to_verify: The "codes" of the specific rules of the package we want to verify contains violations
assert_violates_rules(eval_results, rules_to_verify) if {
	eval_results[_].code == rules_to_verify[_]
	lib.assert_not_equal(count(eval_results), 0)
}

# From https://play.openpolicyagent.org/p/0K5cSyB6vi
reverse_index(path, idx) := value if {
	value := path[count(path) - idx]
}
