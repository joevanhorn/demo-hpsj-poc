# ==============================================================================
# HPSJ Demo - Generic Database Infrastructure
# ==============================================================================
# PostgreSQL RDS instance representing the Optum CES backend database.
# Deployed via: gh workflow run generic-db-deploy.yml -f environment=demo-hpsj-poc -f action=apply
# ==============================================================================

terraform {
  required_version = ">= 1.9.0"

  backend "s3" {
    bucket         = "okta-terraform-demo"
    key            = "Okta-GitOps/demo-hpsj-poc/generic-db/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "okta-terraform-state-lock"
  }
}

provider "aws" {
  region = "us-east-2"
}

# ==============================================================================
# GENERIC DB CONNECTOR MODULE
# ==============================================================================

module "generic_db" {
  source = "../../../modules/generic-db-connector"

  name_prefix = "demo-hpsj-poc-use2"
  environment = "demo-hpsj-poc"

  # Creates its own VPC
  # use_existing_vpc = false

  # Database Configuration
  db_name           = "okta_connector"
  db_username       = "oktaadmin"
  postgres_version  = "15.10"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  # Restrict DB access to VPC CIDR (OPC agent connects from within VPC)
  publicly_accessible = false
  db_allowed_cidrs    = ["10.5.0.0/16"]

  tags = {
    Demo    = "HPSJ-Optum-CES"
    Owner   = "joevanhorn"
    Purpose = "Generic-DB-Connector-Demo"
  }
}

# ==============================================================================
# OUTPUTS
# ==============================================================================

output "db_endpoint" {
  value = module.generic_db.db_endpoint
}

output "jdbc_url" {
  value = module.generic_db.jdbc_url
}

output "credentials_secret" {
  value = module.generic_db.credentials_secret_name
}

output "vpc_id" {
  value = module.generic_db.vpc_id
}

output "subnet_ids" {
  value = module.generic_db.subnet_ids
}

output "security_group_id" {
  value = module.generic_db.security_group_id
}

output "connection_info" {
  value = module.generic_db.connection_info
}
