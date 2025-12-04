terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Management / Org provider - use your management-account credentials
provider "aws" {
  alias  = "mgmt"
  region = var.aws_region
}
