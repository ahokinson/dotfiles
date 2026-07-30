# METADATA
# scope: package
# title: Git push safety
# custom:
#   severity: HIGH
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.git.push

import rego.v1

# GIT-001 — force-push to a protected branch (irreversible to shared history).
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bgit\s+push\b`, input.tool_input.command)
	regex.match(`(--force\b|--force-with-lease\b|(^|\s)-f\b)`, input.tool_input.command)
	regex.match(`\b(main|master|origin/main|origin/master)\b`, input.tool_input.command)
	decision := {
		"rule_id": "GIT-001",
		"reason": "Blocked: force-push to main/master — rebase locally and open a PR, or push a feature branch.",
		"severity": "HIGH",
	}
}
