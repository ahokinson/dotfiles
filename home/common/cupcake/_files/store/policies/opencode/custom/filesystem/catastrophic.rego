# METADATA
# scope: package
# title: Catastrophic disk / process destruction
# custom:
#   severity: CRITICAL
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.filesystem.catastrophic

import rego.v1

# Irreversible local destruction — halt (never-allow, cannot be overridden), not deny.

# FILESYSTEM-005 — dd writing to a raw disk device (wipes a disk).
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bdd\b.*\bof=/dev/(disk|rdisk|sd|nvme|hd|vd)`, input.tool_input.command)
	decision := {
		"rule_id": "FILESYSTEM-005",
		"reason": "Blocked: dd to a raw disk device overwrites the disk irreversibly.",
		"severity": "CRITICAL",
	}
}

# FILESYSTEM-006 — creating a new filesystem (destroys existing data).
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bmkfs(\.\w+)?\b|\bnewfs\b|\bdiskutil\s+erase`, input.tool_input.command)
	decision := {
		"rule_id": "FILESYSTEM-006",
		"reason": "Blocked: formatting/erasing a filesystem destroys all data on the target.",
		"severity": "CRITICAL",
	}
}

# FILESYSTEM-007 — redirecting output onto a raw block device.
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`>\s*/dev/(disk|rdisk|sd|nvme|hd|vd)`, input.tool_input.command)
	decision := {
		"rule_id": "FILESYSTEM-007",
		"reason": "Blocked: redirecting output onto a raw block device corrupts the disk.",
		"severity": "CRITICAL",
	}
}

# FILESYSTEM-008 — fork bomb (local resource-exhaustion DoS). Matches the `{ :|:& }` core.
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`\{\s*:\s*\|\s*:\s*&\s*\}`, input.tool_input.command)
	decision := {
		"rule_id": "FILESYSTEM-008",
		"reason": "Blocked: fork bomb — exhausts process/PID resources and hangs the machine.",
		"severity": "CRITICAL",
	}
}
