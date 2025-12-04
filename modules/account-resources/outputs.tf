output "s3_bucket" {
  description = "S3 bucket created in this account"
  value       = aws_s3_bucket.account_log_bucket.id
}

output "iam_users" {
  description = "List of IAM users created in this account"
  value       = aws_iam_user.users[*].name
}
