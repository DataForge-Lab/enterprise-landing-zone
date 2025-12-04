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
```

