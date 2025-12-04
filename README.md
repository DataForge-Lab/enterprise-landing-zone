# enterprise-landing-zone
This repository contains an Infrastructure-as-Code implementation of an AWS Landing Zone designed to establish a secure, scalable, multi-account cloud foundation. It automates organizational governance, account provisioning, centralized logging, monitoring, and baseline security controls using Terraform.

```text
AWS ORGANIZATION
│
├── Root
│   ├── Attached SCP:
│   │   • deny-root.json
│   │
│   └── Organizational Units
│
├── Security OU
│   ├── Accounts created by Terraform:
│   │   • Security Account
│   │   • Audit Account
│   │
│   └── Attached SCPs:
│       • deny-disable-cloudtrail.json
│
├── Logging OU
│   └── Accounts:
│       • Log Archive Account (planned, not created yet)
│
└── Workloads OU
    ├── Accounts created by Terraform:
    │   • Dev Account
    │   • Test Account
    │   • Prod Account
    │
    └── Attached SCPs:
        • deny-unapproved-regions.json

Structure build by Terraform

AWS ORGANIZATION (Root)
│
├── Security OU
│   ├── Security Account
│   └── Audit Account
│   └── SCP: block cloudtrail disabling
│
├── Logging OU
│   └── Log Archive Account (central logging)
│
└── Workloads OU
    ├── Dev Account
    ├── Test Account
    └── Prod Account
    └── SCP: restrict regions

Purpose of this project:

| Objective                                    | Value                     |
| -------------------------------------------- | ------------------------- |
| Learn AWS multi-account governance           | ⭐ Hands-on experience     |
| Build reusable Landing Zone baseline         | 💼 Professional readiness |
| Enable security & auditability from Day-1    | 🔐 Compliance-focused     |
| Expand later into Production-grade framework | 🚀 Scalable evolution     |

It implements the following design:

- Creates the Organization OUs: Security, Logging, Workloads
- Creates accounts (via Terraform) in those OUs: Security, Audit, LogArchive, Dev, Test, Prod 
- Attaches the SCPs you specified (root / Security OU / Workloads OU)
- Creates an organization-wide CloudTrail writing to a central S3 Log Archive bucket (in the LogArchive account)
- IAM model = A (IAM users in member accounts) — module available to create per-account IAM users & S3, applied in Phase 2

-Provides a bootstrap method (CloudFormation StackSet) to deploy a role into new accounts so you can run per-account Terraform (Phase 2) from the management account


**Enterprise Landing Zone — Pilot (Terraform)**

This repository bootstraps a multi-account AWS Landing Zone:
- Creates Organization OUs: Security, Logging, Workloads
- Creates Accounts: Security, Audit, LogArchive, Dev, Test, Prod
- Attaches SCPs to Root, Security OU, Workloads OU
- Creates centralized CloudTrail writing to Log Archive S3 bucket
- Provides Phase-2 module to create per-account IAM users and S3 buckets
- Provides CloudFormation StackSet template to deploy a bootstrap role to member accounts

> **Phases**
> - **Phase 1 (management account):** run Terraform to create OUs, accounts, SCPs, log bucket and org CloudTrail.
> - **Phase 1.5:** deploy CloudFormation StackSet (bootstrap role) to member accounts so the management account can assume a role in member accounts.
> - **Phase 2 (per-account):** assume the bootstrap role in each member account (via Terraform provider `assume_role`) and apply `modules/account-resources` to create per-account IAM users & S3 buckets.

---

## Quick start

1. Clone repository:
```bash
git clone https://github.com/<your-username>/enterprise-landing-zone.git
cd enterprise-landing-zone

```

