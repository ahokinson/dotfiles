# METADATA
# scope: package
# title: Background persistence
# custom:
#   severity: MEDIUM
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.integrity.persistence

import rego.v1

# INTEGRITY-004 — install a launch agent / daemon (persistence).
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\blaunchctl\s+(load|bootstrap|enable)\b|/Launch(Agents|Daemons)/`, input.tool_input.command)
	decision := {
		"rule_id": "INTEGRITY-004",
		"reason": "Blocked: installing a launch agent/daemon persistence — set it up yourself if intended.",
		"severity": "MEDIUM",
	}
}

# INTEGRITY-005 — install cron persistence.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bcrontab\s+`, input.tool_input.command)
	decision := {
		"rule_id": "INTEGRITY-005",
		"reason": "Blocked: installing cron persistence — set it up yourself if intended.",
		"severity": "MEDIUM",
	}
}
