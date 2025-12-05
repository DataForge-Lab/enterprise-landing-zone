```text
enterprise-landing-zone-demo/
├── README.md
├── provider.tf
├── variables.tf
├── terraform.tfvars.example
├── main.tf
├── outputs.tf
├── scp/
│   ├── deny-root.json
│   ├── deny-disable-cloudtrail.json
│   └── deny-unapproved-regions.json
├── modules/
│   ├── account-resources/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── bootstrap-stackset/         # CloudFormation StackSet template to create bootstrap role in member accounts
│       ├── template.yaml
│       └── README-stackset.md
└── terraform.tfvars                 # (you will fill values; example provided)

View Modules

[ROOT / Management Account]
  | SCP: deny-root.json
  | CloudTrail (org-wide)
  | Config Recorder
  | Log Bucket: log_archive_bucket
  | Outputs: created_accounts, log_archive_bucket
        |
        ├─────────────┐
        |             |
[Security OU]     [Workloads OU]        [Logging OU]
  | SCP: deny-disable-cloudtrail.json   | SCP: deny-unapproved-regions.json
  |                                     |
  ├── Security Account                  ├── Dev Account
  │   | Outputs: s3_bucket, iam_users   │   | Outputs: s3_bucket, iam_users
  └── Audit Account                     ├── Test Account
      | Outputs: s3_bucket, iam_users   │   | Outputs: s3_bucket, iam_users
                                         └── Prod Account
                                             | Outputs: s3_bucket, iam_users
  └── Log Archive Account
      | Outputs: s3_bucket, iam_users

Flow Arrows:
- ROOT outputs (created_accounts, log_archive_bucket) → Phase 2 per-account modules
- Each OU → accounts inside OU
- Phase 2 modules → IAM users + S3 buckets per account

```
