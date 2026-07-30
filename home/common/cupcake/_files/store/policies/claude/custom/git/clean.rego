# METADATA
# scope: package
# title: Destructive git clean
# custom:
#   severity: HIGH
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.git.clean

import rego.v1

# GIT-008 — `git clean -f`/`-fd`/`--force` deletes untracked files for good.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`(?i)\bgit\b[^;&|]*\bclean\b[^;&|]*(-[a-z]*f[a-z]*|--force)\b`, input.tool_input.command)
	decision := {
		"rule_id": "GIT-008",
		"reason": "Blocked: `git clean -f` deletes untracked files irrecoverably — run it yourself if intended.",
		"severity": "HIGH",
	}
}
