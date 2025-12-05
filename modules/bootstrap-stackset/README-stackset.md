# Deploying the bootstrap StackSet

This CloudFormation template creates an `lz-bootstrap-role` in target accounts that the management account can assume.

Steps:

1. From the Management account, create the StackSet:
   - either via Console (CloudFormation > StackSets > Create StackSet) or CLI.

2. CLI example:
```bash
aws cloudformation create-stack-set \
  --stack-set-name lz-bootstrap-role-set \
  --template-body file://modules/bootstrap-stackset/template.yaml \
  --parameters ParameterKey=ManagementAccountArn,ParameterValue=arn:aws:iam::<MANAGEMENT_ACCOUNT_ID>:root \
  --capabilities CAPABILITY_NAMED_IAM

3. Create stack instances (target accounts) by account IDs or OU:
aws cloudformation create-stack-instances \
  --stack-set-name lz-bootstrap-role-set \
  --accounts "<acct-id-1>" "<acct-id-2>" \
  --regions eu-west-1

4. Wait until StackSet completes. Each target account will have lz-bootstrap-role.
