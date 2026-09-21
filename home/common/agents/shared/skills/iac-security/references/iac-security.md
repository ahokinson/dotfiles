# Infrastructure-as-Code Security Reference

## Terraform State Protection

```hcl
terraform {
  backend "s3" {
    bucket         = "org-terraform-state"
    key            = "environments/production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/abcd-1234"
    dynamodb_table = "terraform-state-lock"
  }
}
```

- Encrypt at rest with SSE-KMS (not SSE-S3). Lock state with DynamoDB.
- Restrict access to CI service account and break-glass admin role.
- Never commit `*.tfstate`. Pin provider/module versions exactly. Mark secrets
  `sensitive = true`.

## Policy-as-Code with OPA/Conftest

```bash
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json
conftest test tfplan.json --policy policy/ --all-namespaces
```

```rego
package terraform.security

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_iam_role_policy"
    policy := json.unmarshal(resource.change.after.policy)
    statement := policy.Statement[_]
    statement.Action == "*"
    msg := sprintf("IAM policy %s uses wildcard Action", [resource.address])
}

deny[msg] {
    resource := input.resource_changes[_]
    resource.type == "aws_db_instance"
    resource.change.after.storage_encrypted != true
    msg := sprintf("RDS instance %s has no storage encryption", [resource.address])
}
```

## Kubernetes RBAC

Bad, app bound to `cluster-admin`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: app-admin
subjects:
  - kind: ServiceAccount
    name: app
    namespace: default
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

Good, namespace-scoped Role with specific resources:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: production
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    resourceNames: ["app-config"]
    verbs: ["get", "watch"]
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["app-secrets"]
    verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-role-binding
  namespace: production
subjects:
  - kind: ServiceAccount
    name: app
    namespace: production
roleRef:
  kind: Role
  name: app-role
  apiGroup: rbac.authorization.k8s.io
```

Checklist: No `cluster-admin` for apps. No wildcard verbs/resources. Use
`resourceNames`. Set `automountServiceAccountToken: false` unless needed.

## Network Policies

Default-deny, then allow specific flows:

```yaml
# Default deny all
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}
  policyTypes: [Ingress, Egress]
---
# Allow specific traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-policy
  namespace: production
spec:
  podSelector:
    matchLabels: { app: web }
  policyTypes: [Ingress, Egress]
  ingress:
    - from:
        - namespaceSelector: { matchLabels: { name: ingress-system } }
          podSelector: { matchLabels: { app: nginx-ingress } }
      ports: [{ protocol: TCP, port: 8080 }]
  egress:
    - to:
        - podSelector: { matchLabels: { app: database } }
      ports: [{ protocol: TCP, port: 5432 }]
    - to:  # DNS
        - namespaceSelector: {}
          podSelector: { matchLabels: { k8s-app: kube-dns } }
      ports: [{ protocol: UDP, port: 53 }, { protocol: TCP, port: 53 }]
```

## Common Misconfigurations

### Overly Permissive IAM

Bad: `Action: "*"`, `Resource: "*"`. Fixed, scope to specific actions and
resources:

```hcl
resource "aws_iam_role_policy" "app" {
  role = aws_iam_role.app.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "${aws_s3_bucket.app_data.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage"]
        Resource = aws_sqs_queue.app_queue.arn
      }
    ]
  })
}
```

### Public S3 Buckets

Always add public access block and encryption:

```hcl
resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}
```

### Unencrypted Storage

| Resource | Terraform Attribute | Default |
|---|---|---|
| `aws_db_instance` | `storage_encrypted = true` | false |
| `aws_ebs_volume` | `encrypted = true` | false |
| `aws_efs_file_system` | `encrypted = true` | false |
| `aws_elasticache_replication_group` | `at_rest_encryption_enabled = true` | false |
| `aws_kinesis_stream` | `encryption_type = "KMS"` | NONE |
| `aws_sns_topic` | `kms_master_key_id` | none |
| `aws_sqs_queue` | `kms_master_key_id` | none |

## Static Analysis (tfsec)

| Rule ID | Description | Severity |
|---|---|---|
| `aws-s3-enable-bucket-encryption` | S3 without encryption | HIGH |
| `aws-s3-block-public-access` | S3 missing public access block | CRITICAL |
| `aws-iam-no-policy-wildcards` | IAM wildcard actions/resources | CRITICAL |
| `aws-vpc-no-public-ingress-sgr` | SG allows `0.0.0.0/0` ingress | CRITICAL |
| `aws-rds-encrypt-instance-storage` | RDS without encryption | HIGH |
| `aws-ec2-enforce-http-token-imds` | EC2 not using IMDSv2 | HIGH |

Run tfsec and checkov in CI on every PR. Schedule drift detection daily with
`terraform plan -detailed-exitcode`; treat drift as a security event.
