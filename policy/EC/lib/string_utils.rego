#Original found at https://github.com/enterprise-contract/ec-policies/blob/567c9f57007271f2790b7e035d636c226194af7e/policy/lib/string_utils.rego
package ec.lib

import rego.v1

quoted_values_string(value_list) := result if {
	quoted_list := [quoted_item |
		some item in value_list
		quoted_item := sprintf("'%s'", [item])
	]

	result := concat(", ", quoted_list)
}
