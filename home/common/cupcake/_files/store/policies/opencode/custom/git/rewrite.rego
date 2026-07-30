# METADATA
# scope: package
# title: Git history rewrite
# custom:
#   severity: HIGH
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.git.rewrite

import rego.v1

# GIT-002 — history rewrite with filter-branch.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bgit\s+filter-branch\b`, input.tool_input.command)
	decision := {
		"rule_id": "GIT-002",
		"reason": "Blocked: `git filter-branch` rewrites shared history — do it deliberately, yourself.",
		"severity": "HIGH",
	}
}

# GIT-003 — history rewrite with filter-repo.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bgit\s+filter-repo\b`, input.tool_input.command)
	decision := {
		"rule_id": "GIT-003",
		"reason": "Blocked: `git filter-repo` rewrites shared history — do it deliberately, yourself.",
		"severity": "HIGH",
	}
}
