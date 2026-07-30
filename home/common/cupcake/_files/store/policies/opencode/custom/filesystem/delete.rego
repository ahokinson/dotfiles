# METADATA
# scope: package
# title: Destructive recursive delete
# custom:
#   severity: CRITICAL
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.filesystem.delete

import rego.v1

# recursive + force rm, in either flag order (-rf, -fr, -Rf, ...). One concept.
rm_recursive_force(cmd) if regex.match(`\brm\s+-\S*r\S*f`, cmd)

rm_recursive_force(cmd) if regex.match(`\brm\s+-\S*f\S*r`, cmd)

# A recursive force-delete of root/system/home is never legitimate for an agent — halt
# (never-allow), not deny.

# FILESYSTEM-001 — recursive force-delete of root or a system directory.
halt contains decision if {
	input.tool_name == "Bash"
	rm_recursive_force(input.tool_input.command)
	regex.match(`(\s|=)(/(\s|"|'|$)|/etc|/usr|/bin|/sbin|/var|/System|/Library)`, input.tool_input.command)
	decision := {
		"rule_id": "FILESYSTEM-001",
		"reason": "Blocked: recursive force-delete of root/system path — scope the delete to your workspace.",
		"severity": "CRITICAL",
	}
}

# FILESYSTEM-002 — recursive force-delete of the home directory.
halt contains decision if {
	input.tool_name == "Bash"
	rm_recursive_force(input.tool_input.command)
	regex.match(`(\s|=)(~|\$HOME)(\s|/|"|'|$)`, input.tool_input.command)
	decision := {
		"rule_id": "FILESYSTEM-002",
		"reason": "Blocked: recursive force-delete of your home directory — scope the delete to your workspace.",
		"severity": "CRITICAL",
	}
}
