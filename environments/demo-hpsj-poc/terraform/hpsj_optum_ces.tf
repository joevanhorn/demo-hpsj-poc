# ==============================================================================
# HPSJ - Optum CES (Claims Edit System)
# ==============================================================================
#
# Optum CES is a healthcare claims editing/processing platform. The app is
# an OIN Generic Database Connector set up manually in Okta Admin UI. This
# config manages access groups, department groups, and group-to-app assignments.
#
# The Generic DB Connector reads users/groups/entitlements from the PostgreSQL
# database deployed in generic-db-infrastructure/.
#
# ==============================================================================

# ==============================================================================
# App Reference — Generic DB Connector app (created in Okta Admin UI)
# ==============================================================================

locals {
  optum_ces_app_id = "0oav81kskg950Qm9w1d7"
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
  app_id   = local.optum_ces_app_id
  group_id = okta_group.ces_enterprise_admin.id
}

resource "okta_app_group_assignment" "ces_administrator" {
  app_id   = local.optum_ces_app_id
  group_id = okta_group.ces_administrator.id
}

resource "okta_app_group_assignment" "ces_claims_reviewer" {
  app_id   = local.optum_ces_app_id
  group_id = okta_group.ces_claims_reviewer.id
}

resource "okta_app_group_assignment" "ces_system_view_only" {
  app_id   = local.optum_ces_app_id
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
