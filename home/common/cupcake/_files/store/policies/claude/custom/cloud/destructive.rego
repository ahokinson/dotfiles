# METADATA
# scope: package
# title: Destructive cloud-provider operations
# custom:
#   severity: HIGH
#   routing:
#     required_events: ["PreToolUse"]
#     required_tools: ["Bash"]
package cupcake.global.policies.cloud.destructive

import rego.v1

# Teardown of real infrastructure — deny with a "do it yourself" reason (legitimate, but
# never something an agent should trigger unattended).

# CLOUD-001 — terraform / opentofu destroy.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\b(terraform|tofu)\s+destroy\b`, input.tool_input.command)
	decision := {
		"rule_id": "CLOUD-001",
		"reason": "Blocked: `terraform destroy` tears down real infrastructure — run it yourself if intended.",
		"severity": "HIGH",
	}
}

# CLOUD-002 — kubectl delete of a namespace or all resources.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bkubectl\s+delete\b`, input.tool_input.command)
	regex.match(`\b(namespace|ns)\b|--all\b`, input.tool_input.command)
	decision := {
		"rule_id": "CLOUD-002",
		"reason": "Blocked: `kubectl delete` of a namespace/--all is broadly destructive — run it yourself if intended.",
		"severity": "HIGH",
	}
}

# CLOUD-003 — kubectl drain a node.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bkubectl\s+drain\b`, input.tool_input.command)
	decision := {
		"rule_id": "CLOUD-003",
		"reason": "Blocked: `kubectl drain` evicts workloads from a node — run it yourself if intended.",
		"severity": "HIGH",
	}
}

# CLOUD-004 — AWS terminate EC2 instances.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\baws\s+ec2\s+terminate-instances\b`, input.tool_input.command)
	decision := {
		"rule_id": "CLOUD-004",
		"reason": "Blocked: terminating EC2 instances is destructive — run it yourself if intended.",
		"severity": "HIGH",
	}
}

# CLOUD-005 — AWS IAM delete.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\baws\s+iam\s+delete-`, input.tool_input.command)
	decision := {
		"rule_id": "CLOUD-005",
		"reason": "Blocked: deleting IAM entities can lock out access — run it yourself if intended.",
		"severity": "HIGH",
	}
}

# CLOUD-006 — AWS S3 recursive delete.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\baws\s+s3\s+rm\b.*--recursive`, input.tool_input.command)
	decision := {
		"rule_id": "CLOUD-006",
		"reason": "Blocked: recursive S3 delete removes objects irreversibly — run it yourself if intended.",
		"severity": "HIGH",
	}
}

# CLOUD-007 — gcloud delete.
deny contains decision if {
	input.tool_name == "Bash"
	regex.match(`\bgcloud\b.*\bdelete\b`, input.tool_input.command)
	decision := {
		"rule_id": "CLOUD-007",
		"reason": "Blocked: `gcloud ... delete` removes cloud resources — run it yourself if intended.",
		"severity": "HIGH",
	}
}
