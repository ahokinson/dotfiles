# METADATA
# scope: package
# title: Destructive git reset
# custom:
#   severity: HIGH
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.git.reset

import rego.v1

# GIT-007 — `git reset --hard` throws away uncommitted tracked changes.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`(?i)\bgit\b[^;&|]*\breset\b[^;&|]*--hard\b`, input.tool_input.command)
	decision := {
		"rule_id": "GIT-007",
		"reason": "Blocked: `git reset --hard` discards uncommitted work — run it yourself if intended.",
		"severity": "HIGH",
	}
}
