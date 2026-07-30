# METADATA
# scope: package
# title: Download-and-execute
# custom:
#   severity: HIGH
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.network.download_exec

import rego.v1

# Defense-in-depth vs tirith (Layer 1 also catches pipe-to-shell). Running a remote script
# unreviewed is how most supply-chain compromises land.

# NETWORK-006 — curl piped straight into a shell.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bcurl\b.*\|\s*(sh|bash|zsh|fish)\b`, input.tool_input.command)
	decision := {
		"rule_id": "NETWORK-006",
		"reason": "Blocked: piping curl into a shell runs unreviewed remote code — download, inspect, then run.",
		"severity": "HIGH",
	}
}

# NETWORK-007 — wget piped straight into a shell.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bwget\b.*\|\s*(sh|bash|zsh|fish)\b`, input.tool_input.command)
	decision := {
		"rule_id": "NETWORK-007",
		"reason": "Blocked: piping wget into a shell runs unreviewed remote code — download, inspect, then run.",
		"severity": "HIGH",
	}
}

# NETWORK-008 — shell reading a remote script via process substitution.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\b(sh|bash|zsh|fish)\s+<\(\s*(curl|wget)\b`, input.tool_input.command)
	decision := {
		"rule_id": "NETWORK-008",
		"reason": "Blocked: executing a remote script via process substitution runs unreviewed code — download, inspect, then run.",
		"severity": "HIGH",
	}
}
