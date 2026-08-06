# METADATA
# scope: package
# title: Ripgrep replace-flag footgun
# custom:
#   severity: MEDIUM
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.tools.ripgrep

import rego.v1

# TOOLS-001 — `rg -r` is --replace, not --recursive. ripgrep already recurses, so
# `-r` is never needed for that, and borrowing the flag from `grep -r` makes rg
# rewrite every match to the next argument and exit 0. The output looks like a
# search result and is not, which is worse than an error. Short-flag clusters are
# bounded to 3 characters so `-r`, `-rn`, `-nr`, `-inr` match while a dashed
# pattern argument does not; an explicitly spelled `--replace` is left alone
# because that spelling is unambiguously deliberate. `[^;&|]*` keeps the flag
# attributed to rg rather than a later command in the pipeline.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`(^|[\s;&|/])rg\b[^;&|]*\s-[a-zA-Z0-9]{0,3}r`, input.tool_input.command)
	decision := {
		"rule_id": "TOOLS-001",
		"reason": "Blocked: `rg -r` is --replace, not --recursive — ripgrep recurses by default and -r silently rewrites every match. Drop the flag, or spell out --replace if substitution is genuinely wanted.",
		"severity": "MEDIUM",
	}
}
