# METADATA
# scope: package
# title: Fetch SSRF / metadata / local-file
# custom:
#   severity: HIGH
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash", "WebFetch"]
package cupcake.global.policies.network.fetch

import rego.v1

# The text to scan: a WebFetch URL, or a Bash command line. Undefined for other tools, so
# a rule that reads it simply doesn't fire.
scan_text := input.tool_input.url if input.tool_name == "WebFetch"

scan_text := input.tool_input.command if input.tool_name == "Bash"

# NETWORK-009 — WebFetch of a file:// URL reads a local file through the fetch tool.
deny contains decision if {
	input.tool_name == "WebFetch"
	regex.match(`(?i)file://`, input.tool_input.url)
	decision := {
		"rule_id": "NETWORK-009",
		"reason": "Blocked: file:// via WebFetch reads local files — read the file directly instead.",
		"severity": "HIGH",
	}
}

# NETWORK-010 — cloud instance-metadata endpoint (SSRF → credential theft). WebFetch or Bash.
deny contains decision if {
	regex.match(`169\.254\.169\.254|metadata\.google\.internal|100\.100\.100\.200|metadata\.azure`, scan_text)
	decision := {
		"rule_id": "NETWORK-010",
		"reason": "Blocked: the cloud metadata endpoint is an SSRF credential-theft target.",
		"severity": "HIGH",
	}
}

# NETWORK-011 — WebFetch to loopback / private-range hosts (SSRF into internal services).
# Bash is intentionally exempt (localhost dev servers are routine there).
deny contains decision if {
	input.tool_name == "WebFetch"
	regex.match(`(?i)://(localhost|127\.0\.0\.1|0\.0\.0\.0|\[::1\]|10\.\d+\.\d+\.\d+|192\.168\.\d+\.\d+|172\.(1[6-9]|2\d|3[01])\.\d+\.\d+)\b`, input.tool_input.url)
	decision := {
		"rule_id": "NETWORK-011",
		"reason": "Blocked: WebFetch to a loopback/private-range host is an SSRF vector into internal services.",
		"severity": "HIGH",
	}
}
