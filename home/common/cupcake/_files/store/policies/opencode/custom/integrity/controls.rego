# METADATA
# scope: package
# title: Disabling OS security controls
# custom:
#   severity: CRITICAL
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.integrity.controls

import rego.v1

# Disabling OS integrity controls is never appropriate for an agent — halt (never-allow,
# cannot be overridden), not deny.

# INTEGRITY-001 — disable Gatekeeper.
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`spctl\s+(--master-disable|--global-disable)`, input.tool_input.command)
	decision := {
		"rule_id": "INTEGRITY-001",
		"reason": "Blocked: disabling Gatekeeper (spctl) is never appropriate for an agent.",
		"severity": "CRITICAL",
	}
}

# INTEGRITY-002 — disable System Integrity Protection.
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`csrutil\s+disable`, input.tool_input.command)
	decision := {
		"rule_id": "INTEGRITY-002",
		"reason": "Blocked: disabling SIP (csrutil) is never appropriate for an agent.",
		"severity": "CRITICAL",
	}
}

# INTEGRITY-003 — tamper with boot arguments.
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bnvram\b.*boot-args`, input.tool_input.command)
	decision := {
		"rule_id": "INTEGRITY-003",
		"reason": "Blocked: changing NVRAM boot-args is never appropriate for an agent.",
		"severity": "CRITICAL",
	}
}
