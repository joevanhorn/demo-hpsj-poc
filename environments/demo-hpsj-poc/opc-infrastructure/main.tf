# ==============================================================================
# HPSJ Demo - OPC Agent Infrastructure
# ==============================================================================
# Okta On-Prem Connector agent for Generic DB connectivity.
# Deployed via: gh workflow run opc-deploy.yml -f environment=demo-hpsj-poc -f action=apply
#
# Prerequisites: Generic DB must be deployed first (provides VPC/subnet/SG).
# ==============================================================================

terraform {
  required_version = ">= 1.9.0"

  backend "s3" {
    bucket         = "okta-terraform-demo"
    key            = "Okta-GitOps/demo-hpsj-poc/opc-infrastructure/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "okta-terraform-state-lock"
  }
}

provider "aws" {
  region = "us-east-2"
}

# ==============================================================================
# DATA: Get Generic DB outputs for networking
# ==============================================================================

data "terraform_remote_state" "generic_db" {
  backend = "s3"

  config = {
    bucket = "okta-terraform-demo"
    key    = "Okta-GitOps/demo-hpsj-poc/generic-db/terraform.tfstate"
    region = "us-east-1"
  }
}

# ==============================================================================
# Okta SWG Security Group — allows Okta SWG IPs for EC2 instances
# ==============================================================================

module "okta_swg_sg" {
  source = "../../../modules/okta-swg-security-group"
  vpc_id = data.terraform_remote_state.generic_db.outputs.vpc_id

  tags = {
    Demo    = "HPSJ-Optum-CES"
    Owner   = "joevanhorn"
    Purpose = "Okta-SWG-Access"
  }
}

# ==============================================================================
# OPC AGENT — single instance for demo
# ==============================================================================

locals {
  opc_agents = {
    "generic-db-1" = { instance_number = 1 }
  }
}

module "opc_agents" {
  source   = "../../../modules/opc-agent"
  for_each = local.opc_agents

  environment     = "demo-hpsj-poc"
  region_short    = "use2"
  connector_type  = "generic-db"
  instance_number = each.value.instance_number

  # Networking (from Generic DB module outputs)
  vpc_id             = data.terraform_remote_state.generic_db.outputs.vpc_id
  subnet_id          = data.terraform_remote_state.generic_db.outputs.subnet_ids[0]
  security_group_ids = [
    data.terraform_remote_state.generic_db.outputs.security_group_id,
    module.okta_swg_sg.security_group_id,
  ]

  # Okta configuration
  okta_org_url    = "https://demo-hpsj-poc.okta.com"
  database_host   = data.terraform_remote_state.generic_db.outputs.db_endpoint
  jdbc_driver_url = "https://jdbc.postgresql.org/download/postgresql-42.7.4.jar"

  # Full bootstrap from stock RHEL 8 AMI (no pre-built AMI shared to this account)
  # use_prebuilt_ami = false  (default)

  tags = {
    Demo    = "HPSJ-Optum-CES"
    Owner   = "joevanhorn"
    Purpose = "OPC-Agent-Generic-DB"
  }
}

# ==============================================================================
# OUTPUTS
# ==============================================================================

output "opc_agents" {
  value = { for k, v in module.opc_agents : k => {
    instance_id = v.instance_id
    private_ip  = v.private_ip
    public_ip   = v.public_ip
    ssm_command = v.ssm_session_command
  }}
}

output "okta_swg_security_group_id" {
  value = module.okta_swg_sg.security_group_id
}
