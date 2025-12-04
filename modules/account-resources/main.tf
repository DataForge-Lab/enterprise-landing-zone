variable "account_name" { type = string }
variable "s3_bucket_name" { type = string }
variable "iam_users" { type = list(string) default = ["demo-user"] }

resource "aws_s3_bucket" "account_log_bucket" {
  bucket = var.s3_bucket_name

  versioning { enabled = true }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
    }
  }

  tags = { Name = var.s3_bucket_name, Account = var.account_name }
}

resource "aws_iam_user" "users" {
  for_each = toset(var.iam_users)
  name     = each.value
}

resource "aws_iam_policy" "read_only" {
  name = "read-only-${var.account_name}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:List*", "ec2:Describe*"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach" {
  for_each   = aws_iam_user.users
  user       = each.value.name
  policy_arn = aws_iam_policy.read_only.arn
}
