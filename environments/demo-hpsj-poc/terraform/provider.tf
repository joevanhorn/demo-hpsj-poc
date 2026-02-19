terraform {
  required_version = ">= 1.9.0"

  required_providers {
    okta = {
      source  = "okta/okta"
      version = ">= 6.4.0, < 7.0.0"
    }
  }

  backend "s3" {
    bucket         = "taskvantage-prod-tf-state"
    key            = "Okta-GitOps/demo-hpsj-poc/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = "taskvantage-prod-tf-state-lock"
  }
}

provider "okta" {
  org_name  = var.okta_org_name
  base_url  = var.okta_base_url
  api_token = var.okta_api_token
}
