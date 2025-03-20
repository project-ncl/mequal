package mequal.main

import data.mequal.leveling
import rego.v1

mequal_L0_violations contains result if {
	# goes 1 layer deep since there are no cdx or spdx format-specific policies
	result := leveling.L0[_].deny[_]
}

mequal_L1_violations contains result if {
	# goes 2 layers deep to go past cdx or spdx layer
	result := leveling.L1[_][_].deny[_]
}

# starting point for an SBOM is L0
default sbom_level := "L0"

# If L0 policies don't return error, SBOM is L1
sbom_level := "L1" if {
	count(mequal_L0_violations) == 0
	count(mequal_L1_violations) != 0
}

# If L0 and L1 policies both have no errors, SBOM is L2
sbom_level := "L2" if {
	count(mequal_L0_violations) == 0
	count(mequal_L1_violations) == 0
}
