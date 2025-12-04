
---

## Prerequisites

- AWS CLI configured for the management account with sufficient permissions  
- Terraform v1.5+ installed  
- Unique email addresses for each AWS account  
- Globally unique S3 bucket name for centralized logs  

---

## Deployment Commands

```bash
# Clone repo and configure variables
git clone https://github.com/<your-username>/enterprise-landing-zone.git
cd enterprise-landing-zone
# Edit terraform.tfvars to set logarchive_bucket_name and account emails

# Initialize Terraform
terraform init

# Phase 1: Create Organization, OUs, Accounts, SCPs, CloudTrail
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

# Check outputs from Root
terraform output created_accounts
terraform output log_archive_bucket

# Move accounts to correct OUs if needed
aws organizations move-account --account-id <ACCOUNT_ID> --source-parent-id <ROOT_ID> --destination-parent-id <OU_ID>

# Phase 1.5: Deploy bootstrap role in member accounts
aws cloudformation create-stack-set \
  --stack-set-name lz-bootstrap-role-set \
  --template-body file://modules/bootstrap-stackset/template.yaml \
  --parameters ParameterKey=ManagementAccountArn,ParameterValue=arn:aws:iam::<MGMT_ACCOUNT_ID>:root \
  --capabilities CAPABILITY_NAMED_IAM

aws cloudformation create-stack-instances \
  --stack-set-name lz-bootstrap-role-set \
  --accounts "<SECURITY_ACCOUNT_ID>" "<AUDIT_ACCOUNT_ID>" "<DEV_ACCOUNT_ID>" "<TEST_ACCOUNT_ID>" "<PROD_ACCOUNT_ID>" "<LOGARCHIVE_ACCOUNT_ID>" \
  --regions eu-west-1

# Phase 2: Per-account resources (example for Dev)
# Configure provider in provider_accounts.tf with assume_role
terraform init
terraform plan -target=module.dev_account_resources -var-file=terraform.tfvars
terraform apply -target=module.dev_account_resources -var-file=terraform.tfvars
terraform output -module=dev_account_resources

# Repeat Phase 2 for all other accounts (Security, Audit, Test, Prod, LogArchive)
