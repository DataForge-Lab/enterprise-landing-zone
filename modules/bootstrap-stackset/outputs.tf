output "bootstrap_role_name" {
  description = "Name of the bootstrap role deployed to member accounts"
  value       = "lz-bootstrap-role"
}

output "bootstrap_role_arn" {
  description = "ARN of the bootstrap role deployed to member accounts"
  value       = "arn:aws:iam::${var.target_account_id}:role/lz-bootstrap-role"
}
