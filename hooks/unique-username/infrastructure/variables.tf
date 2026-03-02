# Variables for Unique Username Hook Infrastructure

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "unique-username-hook"
}

variable "okta_org_url" {
  description = "Okta organization URL (e.g., https://demo-hpsj-poc.okta.com)"
  type        = string
}
