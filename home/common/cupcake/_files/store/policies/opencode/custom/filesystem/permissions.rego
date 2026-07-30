# METADATA
# scope: package
# title: Dangerous permission changes
# custom:
#   severity: HIGH
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.filesystem.permissions

import rego.v1

# FILESYSTEM-003 — recursive world-writable chmod/chown on a broad path.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\b(chmod|chown)\s+-\S*R`, input.tool_input.command)
	regex.match(`(\b777\b|\b666\b)`, input.tool_input.command)
	regex.match(`(\s|=)(/|~|\$HOME|/etc|/usr|/System|/Library)(\s|/|"|'|$)`, input.tool_input.command)
	decision := {
		"rule_id": "FILESYSTEM-003",
		"reason": "Blocked: recursive world-writable chmod/chown on a broad path.",
		"severity": "HIGH",
	}
}

# FILESYSTEM-004 — add the setuid/setgid bit (privilege-escalation vector). Symbolic
# (`u+s`, `g+s`, `+s`) or a 4-digit numeric mode whose leading special digit sets suid/sgid.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bchmod\s+(-\S+\s+)*([ug]?\+s\b|[2467][0-7]{3}\b)`, input.tool_input.command)
	decision := {
		"rule_id": "FILESYSTEM-004",
		"reason": "Blocked: setting the setuid/setgid bit is a privilege-escalation vector — do it yourself if intended.",
		"severity": "HIGH",
	}
}
