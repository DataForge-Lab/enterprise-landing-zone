variable "aws_region" {
  description = "Primary region"
  type        = string
  default     = "eu-west-1"
}

variable "organization_feature_set" {
  type    = string
  default = "ALL"
}

variable "accounts" {
  description = "Accounts to create: map of account_id_key -> {email, ou, create}"
  type = map(object({
    email  = string
    ou     = string
    create = bool
  }))
  default = {
    "security-account" = { email = "security-account+demo@example.com", ou = "Security", create = true }
    "audit-account"    = { email = "audit-account+demo@example.com",    ou = "Security", create = true }
    "logarchive-account" = { email = "logarchive-account+demo@example.com", ou = "Logging", create = true }
    "dev-account"      = { email = "dev-account+demo@example.com",      ou = "Workloads", create = true }
    "test-account"     = { email = "test-account+demo@example.com",     ou = "Workloads", create = true }
    "prod-account"     = { email = "prod-account+demo@example.com",     ou = "Workloads", create = true }
  }
}

variable "allowed_regions" {
  description = "Allowed regions for Workloads OU (for deny-unapproved-regions SCP)"
  type        = list(string)
  default     = ["eu-west-1"]
}

# names for SCP files (stored in scp/)
variable "scp_root_file" {
  default = "scp/deny-root.json"
}
variable "scp_security_file" {
  default = "scp/deny-disable-cloudtrail.json"
}
variable "scp_workloads_file" {
  default = "scp/deny-unapproved-regions.json"
}

# CloudTrail bucket name (will be created in logarchive account via management account)
variable "logarchive_bucket_name" {
  description = "S3 bucket name for centralized logs (CloudTrail + Config)"
  type        = string
  default     = "lz-log-archive-{{org-id}}-eu-west-1" # replace placeholder later or edit terraform.tfvars
}
