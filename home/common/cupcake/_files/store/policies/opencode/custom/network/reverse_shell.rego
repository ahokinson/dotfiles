# METADATA
# scope: package
# title: Reverse shells and bind listeners
# custom:
#   severity: CRITICAL
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.network.reverse_shell

import rego.v1

# One rule per technique. Overlap note: tirith (Layer 1) catches pipe-to-shell /
# homograph URLs.

# NETWORK-001 — /dev/tcp or /dev/udp redirection (bash reverse-shell primitive).
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`/dev/(tcp|udp)/`, input.tool_input.command)
	decision := {
		"rule_id": "NETWORK-001",
		"reason": "Blocked: /dev/tcp redirection is a reverse-shell primitive.",
		"severity": "CRITICAL",
	}
}

# NETWORK-002 — netcat with command execution.
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bnc\b[^|]*\s-\S*e\b`, input.tool_input.command)
	decision := {
		"rule_id": "NETWORK-002",
		"reason": "Blocked: `nc -e` executes a command over the socket (reverse shell).",
		"severity": "CRITICAL",
	}
}

# NETWORK-003 — ncat with command execution.
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bncat\b[^|]*--exec\b`, input.tool_input.command)
	decision := {
		"rule_id": "NETWORK-003",
		"reason": "Blocked: `ncat --exec` executes a command over the socket (reverse shell).",
		"severity": "CRITICAL",
	}
}

# NETWORK-004 — socat with a command endpoint.
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bsocat\b.*\bexec:`, input.tool_input.command)
	decision := {
		"rule_id": "NETWORK-004",
		"reason": "Blocked: `socat exec:` bridges a command to the network (reverse shell).",
		"severity": "CRITICAL",
	}
}

# NETWORK-005 — interactive bash redirected to a socket.
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bbash\s+-i\b.*>&`, input.tool_input.command)
	decision := {
		"rule_id": "NETWORK-005",
		"reason": "Blocked: interactive bash redirected to a socket is a reverse shell.",
		"severity": "CRITICAL",
	}
}
