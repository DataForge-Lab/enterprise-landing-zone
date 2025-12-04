output "created_accounts" {
  description = "Map of created account keys to account IDs"
  value = { for k,a in aws_organizations_account.accounts : k => a.id }
}

output "log_archive_bucket" {
  description = "S3 bucket for centralized CloudTrail logs"
  value       = aws_s3_bucket.org_cloudtrail_bucket.id
}
