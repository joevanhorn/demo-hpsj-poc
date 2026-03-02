terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  # S3 Backend for State Storage
  # Uses the same bucket as the main Okta GitOps state
  backend "s3" {
    bucket         = "okta-terraform-demo"
    key            = "Okta-GitOps/demo-hpsj-poc/hooks/unique-username/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "okta-terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      Component = "Unique-Username-Hook"
      ManagedBy = "Terraform"
    }
  }
}

# Alias to satisfy references in lambda.tf (same provider, single account)
provider "aws" {
  alias  = "lambda"
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      Component = "Unique-Username-Hook"
      ManagedBy = "Terraform"
    }
  }
}

data "aws_caller_identity" "current" {}
