# ==============================================================================
# Okta SWG Security Group Module
# ==============================================================================
# Creates a security group allowing inbound traffic from Okta's Secure Web
# Gateway (SWG) IP ranges via managed prefix lists. Mirrors the manually
# created "Okta-SWG-All-US" security group as a reusable Terraform module.
#
# The prefix lists are managed by Okta (account 088607061497) and shared
# to customer accounts via AWS RAM. They exist in all standard AWS regions.
# ==============================================================================

# ------------------------------------------------------------------------------
# Data: Look up Okta SWG prefix lists by name
# ------------------------------------------------------------------------------

data "aws_ec2_managed_prefix_list" "okta_swg" {
  for_each = toset(var.prefix_list_names)

  filter {
    name   = "prefix-list-name"
    values = [each.value]
  }
}

# ------------------------------------------------------------------------------
# Security Group
# ------------------------------------------------------------------------------

resource "aws_security_group" "okta_swg" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  # Okta corporate CIDR
  ingress {
    description = "Okta corporate network"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["130.0.0.0/8"]
  }

  # One ingress rule per prefix list
  dynamic "ingress" {
    for_each = data.aws_ec2_managed_prefix_list.okta_swg
    content {
      description     = "Okta SWG - ${ingress.key}"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      prefix_list_ids = [ingress.value.id]
    }
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}
