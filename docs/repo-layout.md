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
```
