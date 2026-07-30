# METADATA
# scope: package
# title: Destructive database operations
# custom:
#   severity: HIGH
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.database.destructive

import rego.v1

# DATABASE-001 — DROP DATABASE/TABLE/SCHEMA or TRUNCATE through a SQL client.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\b(psql|mysql|mariadb)\b`, input.tool_input.command)
	regex.match(`(?i)\b(drop\s+(database|table|schema)|truncate\s+table)\b`, input.tool_input.command)
	decision := {
		"rule_id": "DATABASE-001",
		"reason": "Blocked: DROP/TRUNCATE via a SQL client destroys data — run it yourself if intended.",
		"severity": "HIGH",
	}
}

# DATABASE-002 — Redis flush of a whole keyspace.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`(?i)\bredis-cli\b.*\bflush(all|db)\b`, input.tool_input.command)
	decision := {
		"rule_id": "DATABASE-002",
		"reason": "Blocked: `redis-cli FLUSHALL/FLUSHDB` wipes the keyspace — run it yourself if intended.",
		"severity": "HIGH",
	}
}

# DATABASE-003 — MongoDB drop of a collection or database.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`(?i)\bmongo(sh)?\b.*\.drop(database)?\s*\(`, input.tool_input.command)
	decision := {
		"rule_id": "DATABASE-003",
		"reason": "Blocked: dropping a MongoDB collection/database destroys data — run it yourself if intended.",
		"severity": "HIGH",
	}
}
