#----------------------------------------------------------------------#
# Data: read organization (if exists)                                  #
#----------------------------------------------------------------------#
data "aws_organizations_organization" "org" {
  provider = aws.mgmt
}

locals {
  root_id = data.aws_organizations_organization.org.roots[0].id
}

#----------------------------------------------------------------------#
# Create OUs                                                             #
#----------------------------------------------------------------------#
resource "aws_organizations_organizational_unit" "ou" {
  provider = aws.mgmt
  for_each = toset(["Security", "Logging", "Workloads"])
  name     = each.value
  parent_id = local.root_id
}

#----------------------------------------------------------------------#
# Create accounts                                                       #
#----------------------------------------------------------------------#
resource "aws_organizations_account" "accounts" {
  provider = aws.mgmt
  for_each = { for k, v in var.accounts : k => v if v.create }

  name  = each.key
  email = each.value.email

  lifecycle {
    create_before_destroy = true
  }
  # note: provider may not support immediate parent assignment; we will move accounts to OU via awscli if needed
}

#----------------------------------------------------------------------#
# Move accounts into OUs (best-effort)                                 #
#----------------------------------------------------------------------#
# Terraform provider historically had limitations moving accounts.
# Provide a local-exec guidance resource that prints CLI commands (not automated) so you can run them if needed.
resource "null_resource" "move_account_commands" {
  for_each = aws_organizations_account.accounts
  provisioner "local-exec" {
    command = <<EOT
echo "Move account ${each.value.id} to OU ${var.accounts[each.key].ou}:"
echo aws organizations move-account --account-id ${each.value.id} --source-parent-id ${local.root_id} --destination-parent-id ${aws_organizations_organizational_unit.ou[var.accounts[each.key].ou].id}
EOT
  }
}

#----------------------------------------------------------------------#
# Create S C P files as Organization Policies and attach them          #
#----------------------------------------------------------------------#
resource "aws_organizations_policy" "root_scp" {
  provider = aws.mgmt
  name        = "deny-root"
  description = "Deny dangerous root-level actions"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file(var.scp_root_file)
}

resource "aws_organizations_policy_attachment" "attach_root" {
  provider  = aws.mgmt
  policy_id = aws_organizations_policy.root_scp.id
  target_id = local.root_id
}

resource "aws_organizations_policy" "security_scp" {
  provider = aws.mgmt
  name    = "deny-disable-cloudtrail"
  type    = "SERVICE_CONTROL_POLICY"
  content = file(var.scp_security_file)
}

resource "aws_organizations_policy_attachment" "attach_security_scp" {
  provider  = aws.mgmt
  policy_id = aws_organizations_policy.security_scp.id
  target_id = aws_organizations_organizational_unit.ou["Security"].id
}

resource "aws_organizations_policy" "workloads_scp" {
  provider = aws.mgmt
  name    = "deny-unapproved-regions"
  type    = "SERVICE_CONTROL_POLICY"
  content = templatefile("${path.module}/scp/deny-unapproved-regions.json", { allowed_regions = jsonencode(var.allowed_regions) })
}

resource "aws_organizations_policy_attachment" "attach_workloads_scp" {
  provider  = aws.mgmt
  policy_id = aws_organizations_policy.workloads_scp.id
  target_id = aws_organizations_organizational_unit.ou["Workloads"].id
}

#----------------------------------------------------------------------#
# Central Log Archive bucket (created in mgmt account for simplicity)  #
# (If you prefer bucket in LogArchive account we provide steps below)  #
#----------------------------------------------------------------------#
resource "aws_s3_bucket" "org_cloudtrail_bucket" {
  provider = aws.mgmt
  bucket   = var.logarchive_bucket_name
  acl      = "private"

  versioning { enabled = true }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "logs-expire"
    enabled = true
    expiration { days = 365 * 7 }
  }

  tags = {
    Name = "log-archive"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  provider = aws.mgmt
  bucket = aws_s3_bucket.org_cloudtrail_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Allow CloudTrail service to put objects
resource "aws_s3_bucket_policy" "cloudtrail_put" {
  provider = aws.mgmt
  bucket   = aws_s3_bucket.org_cloudtrail_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudTrailPut"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.org_cloudtrail_bucket.arn}/AWSLogs/*"
        Condition = { StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" } }
      }
    ]
  })
}

#----------------------------------------------------------------------#
# Organization-wide CloudTrail                                         #
#----------------------------------------------------------------------#
resource "aws_cloudtrail" "org_trail" {
  provider = aws.mgmt
  name                          = "organization-trail"
  is_organization_trail         = true
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = true
  s3_bucket_name                = aws_s3_bucket.org_cloudtrail_bucket.id
}

#----------------------------------------------------------------------#
# AWS Config recorder (management account)                             #
# Note: Organization-wide config requires delegated admin - see README#
#----------------------------------------------------------------------#
resource "aws_iam_role" "config_role" {
  provider = aws.mgmt
  name = "lz-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "config.amazonaws.com" }
    }]
  })
}

resource "aws_config_configuration_recorder" "recorder" {
  provider = aws.mgmt
  name     = "lz-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
  }
}
