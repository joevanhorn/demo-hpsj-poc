# ==============================================================================
# HPSJ - Optum CES (Claims Edit System)
# ==============================================================================
#
# Optum CES is a healthcare claims editing/processing platform. This
# configuration creates a SAML app with placeholder auth data, access groups
# representing the four CES access levels, and department groups with
# auto-assignment rules.
#
# DEPLOYMENT STAGES:
#   Stage 1: Create SAML app + groups + users (this apply)
#   Stage 2: Manually enable entitlement management on the app in Okta Admin UI
#   Stage 3: Add entitlements + entitlement bundles (next apply)
#
# ==============================================================================

# ==============================================================================
# Stage 1: SAML Application
# ==============================================================================

resource "okta_app_saml" "optum_ces" {
  label                    = "Optum CES"
  sso_url                  = "https://ces.optum.com/sso/saml"
  recipient                = "https://ces.optum.com/sso/saml"
  destination              = "https://ces.optum.com/sso/saml"
  audience                 = "https://ces.optum.com"
  subject_name_id_template = "$${user.userName}"
  subject_name_id_format   = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
  response_signed          = true
  signature_algorithm      = "RSA_SHA256"
  digest_algorithm         = "SHA256"
  honor_force_authn        = true
  authn_context_class_ref  = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"

  attribute_statements {
    name      = "firstName"
    namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    values    = ["user.firstName"]
  }

  attribute_statements {
    name      = "lastName"
    namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    values    = ["user.lastName"]
  }

  attribute_statements {
    name      = "email"
    namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    values    = ["user.email"]
  }

  attribute_statements {
    name      = "department"
    namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    values    = ["user.department"]
  }
}

# ==============================================================================
# CES Access Groups — map to CES application roles
# ==============================================================================

resource "okta_group" "ces_enterprise_admin" {
  name        = "CES-Enterprise-Admin"
  description = "Optum CES Enterprise Admin - full enterprise config, claims, rules, reports, code repo management"
}

resource "okta_group" "ces_administrator" {
  name        = "CES-Administrator"
  description = "Optum CES System Administrator - system config, user/role management, KB loading, DDR, audit logs"
}

resource "okta_group" "ces_claims_reviewer" {
  name        = "CES-Claims-Reviewer"
  description = "Optum CES Claims Reviewer - view-only access to claims data with PHI"
}

resource "okta_group" "ces_system_view_only" {
  name        = "CES-System-View-Only"
  description = "Optum CES System View Only - read-only system-level access"
}

# ==============================================================================
# Group assignments to app
# ==============================================================================

resource "okta_app_group_assignment" "ces_enterprise_admin" {
  app_id   = okta_app_saml.optum_ces.id
  group_id = okta_group.ces_enterprise_admin.id
}

resource "okta_app_group_assignment" "ces_administrator" {
  app_id   = okta_app_saml.optum_ces.id
  group_id = okta_group.ces_administrator.id
}

resource "okta_app_group_assignment" "ces_claims_reviewer" {
  app_id   = okta_app_saml.optum_ces.id
  group_id = okta_group.ces_claims_reviewer.id
}

resource "okta_app_group_assignment" "ces_system_view_only" {
  app_id   = okta_app_saml.optum_ces.id
  group_id = okta_group.ces_system_view_only.id
}

# ==============================================================================
# Department Groups
# ==============================================================================

locals {
  hpsj_departments = {
    "Claims"           = "Claims Operations - processors, analysts, QA, recovery, refunds"
    "Configuration"    = "Configuration Management - config analysts and managers"
    "IS"               = "Information Systems - sysadmins, DBAs, DevOps, security, BI"
    "Pharmacy"         = "Pharmacy - clinical pharmacy management"
    "CMME"             = "Care Management / Medical Economics"
    "Service Delivery" = "Service Delivery - support, data integrity, project management"
  }
}

resource "okta_group" "departments" {
  for_each    = local.hpsj_departments
  name        = "HPSJ-${replace(each.key, " ", "-")}"
  description = "HPSJ ${each.key} Department - ${each.value}"
}

# ==============================================================================
# Group Rules — auto-assign users to department groups by user.department
# ==============================================================================

resource "okta_group_rule" "department_assignment" {
  for_each = okta_group.departments

  name              = "HPSJ ${each.key} Auto-Assign"
  status            = "ACTIVE"
  group_assignments = [each.value.id]
  expression_type   = "urn:okta:expression:1.0"
  expression_value  = "user.department==\"${each.key}\""
}
