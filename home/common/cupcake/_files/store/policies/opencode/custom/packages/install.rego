# METADATA
# scope: package
# title: Global / system package installs
# custom:
#   severity: MEDIUM
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.packages.install

import rego.v1

# One rule per manager. `deny` (not `ask`): a global `ask` is overridden by the
# empty stub project in cupcake 0.3.0, so it never surfaces machine-wide. These
# mutate the machine outside the project — run by hand if intended.

# PACKAGES-001 — npm/pnpm global install.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\b(npm|pnpm)\s+(i|install|add)\b[^|]*(-g\b|--global\b)`, input.tool_input.command)
	decision := {
		"rule_id": "PACKAGES-001",
		"reason": "Blocked: global npm/pnpm install mutates the machine — install into the project, or run it yourself.",
		"severity": "MEDIUM",
	}
}

# PACKAGES-002 — yarn global add.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\byarn\s+global\s+add\b`, input.tool_input.command)
	decision := {
		"rule_id": "PACKAGES-002",
		"reason": "Blocked: `yarn global add` mutates the machine — run it yourself if intended.",
		"severity": "MEDIUM",
	}
}

# PACKAGES-003 — pip user/system install.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bpip3?\s+install\b[^|]*(--user\b|--break-system-packages\b)`, input.tool_input.command)
	decision := {
		"rule_id": "PACKAGES-003",
		"reason": "Blocked: pip --user/--break-system-packages mutates the machine — use a venv, or run it yourself.",
		"severity": "MEDIUM",
	}
}

# PACKAGES-004 — sudo install of a language package.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bsudo\s+(pip3?|gem|npm)\s+install\b`, input.tool_input.command)
	decision := {
		"rule_id": "PACKAGES-004",
		"reason": "Blocked: sudo-installing a language package is machine-wide — run it yourself if intended.",
		"severity": "MEDIUM",
	}
}
