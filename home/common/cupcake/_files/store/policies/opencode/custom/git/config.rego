# METADATA
# scope: package
# title: Git config tampering
# custom:
#   severity: MEDIUM
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.git.config

import rego.v1

# GIT-004 — change commit identity.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bgit\s+config\b`, input.tool_input.command)
	regex.match(`\buser\.(email|name)\b`, input.tool_input.command)
	decision := {
		"rule_id": "GIT-004",
		"reason": "Blocked: changing git commit identity (user.email/user.name) — set it yourself if intended.",
		"severity": "MEDIUM",
	}
}

# GIT-005 — change or disable commit signing.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bgit\s+config\b`, input.tool_input.command)
	regex.match(`(commit\.gpgsign|tag\.gpgsign|user\.signingkey|\bgpg\.)`, input.tool_input.command)
	decision := {
		"rule_id": "GIT-005",
		"reason": "Blocked: changing commit signing config — set it yourself if intended.",
		"severity": "MEDIUM",
	}
}

# GIT-006 — redirect the git hooks path.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bgit\s+config\b`, input.tool_input.command)
	regex.match(`\bcore\.hooksPath\b`, input.tool_input.command)
	decision := {
		"rule_id": "GIT-006",
		"reason": "Blocked: redirecting core.hooksPath can plant malicious hooks — set it yourself if intended.",
		"severity": "HIGH",
	}
}
