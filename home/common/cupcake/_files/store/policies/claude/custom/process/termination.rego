# METADATA
# scope: package
# title: Process termination
# custom:
#   severity: HIGH
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.process.termination

import rego.v1

# PROCESS-001 — kill / pkill / killall. The agent must never terminate processes;
# if one genuinely needs killing, the human runs it. Anchored to a command
# boundary (start, whitespace, shell operator, or path separator) so it catches
# `kill`, `sudo kill`, `/bin/kill`, `pkill`, `killall` but not words like
# "killing" or "killed".
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`(^|[\s;&|/])(killall|pkill|kill)(\s|[;&|]|$)`, input.tool_input.command)
	decision := {
		"rule_id": "PROCESS-001",
		"reason": "Blocked: the agent must not kill processes — run kill/pkill yourself if it is genuinely needed.",
		"severity": "HIGH",
	}
}
