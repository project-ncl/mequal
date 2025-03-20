#Original found at https://github.com/enterprise-contract/ec-policies/blob/567c9f57007271f2790b7e035d636c226194af7e/policy/lib/string_utils_test.rego
package ec.lib_test

import rego.v1

import data.ec.lib

test_quoted_values_string if {
	lib.assert_equal("'a', 'b', 'c'", lib.quoted_values_string(["a", "b", "c"]))
	lib.assert_equal("'a', 'b', 'c'", lib.quoted_values_string({"a", "b", "c"}))
}
