# METADATA
# scope: package
# title: Secret exfiltration
# custom:
#   severity: CRITICAL
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.secrets.exfil

import rego.v1

# One rule per secret source; the network sink is one concept (list of tools).
# Overlap note: READING secret files is covered by the sensitive_data_protection
# builtin + Claude sandbox denyRead. This targets EXFILTRATION over the net.

pipes_to_network(cmd) if regex.match(`\|\s*(curl|wget|nc|ncat|socat|scp|ssh)\b`, cmd)

# SECRETS-001 — the environment dumped to the network.
halt contains decision if {
	input.tool_name == "Bash"
	# `env`/`printenv` at a command position — not the "env" inside a ".env" name.
	regex.match(`(^|[\s;|&(])(env|printenv)\b`, input.tool_input.command)
	pipes_to_network(input.tool_input.command)
	decision := {
		"rule_id": "SECRETS-001",
		"reason": "Blocked: piping the environment to the network exfiltrates secrets.",
		"severity": "CRITICAL",
	}
}

# SECRETS-002 — private keys sent to the network.
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`(id_rsa|id_ed25519|id_ecdsa|id_dsa|\.pem\b|\.key\b)`, input.tool_input.command)
	pipes_to_network(input.tool_input.command)
	decision := {
		"rule_id": "SECRETS-002",
		"reason": "Blocked: sending a private key over the network exfiltrates credentials.",
		"severity": "CRITICAL",
	}
}

# SECRETS-003 — credential stores sent to the network.
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`(\.ssh/|\.aws/|\.gnupg/|\.netrc\b|credentials)`, input.tool_input.command)
	pipes_to_network(input.tool_input.command)
	decision := {
		"rule_id": "SECRETS-003",
		"reason": "Blocked: sending a credential store over the network exfiltrates secrets.",
		"severity": "CRITICAL",
	}
}

# SECRETS-004 — a .env file sent to the network.
halt contains decision if {
	input.tool_name == "Bash"
	regex.match(`(/\.env\b|\.env\.)`, input.tool_input.command)
	pipes_to_network(input.tool_input.command)
	decision := {
		"rule_id": "SECRETS-004",
		"reason": "Blocked: sending a .env file over the network exfiltrates secrets.",
		"severity": "CRITICAL",
	}
}
