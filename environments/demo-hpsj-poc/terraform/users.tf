# ==============================================================================
# HPSJ Demo Users
# ==============================================================================
#
# ~80 users loaded from CSV, distributed across 6 departments and 4 CES
# access levels. Users are created in STAGED status for demo flexibility.
#
# Access group column in CSV is used for CES group membership rules below.
# ==============================================================================

locals {
  hpsj_users     = csvdecode(file("${path.module}/hpsj_users.csv"))
  hpsj_users_map = { for user in local.hpsj_users : user.login => user }
}

resource "okta_user" "hpsj" {
  for_each = local.hpsj_users_map

  first_name = each.value.first_name
  last_name  = each.value.last_name
  login      = each.value.login
  email      = each.value.email
  department = each.value.department
  title      = each.value.title

  lifecycle {
    ignore_changes = [manager_id]
  }
}

# ==============================================================================
# CES Access Group Membership — assign users to access groups based on CSV
# ==============================================================================

locals {
  # Group users by access_group column from CSV
  enterprise_admin_users = {
    for k, v in local.hpsj_users_map : k => v if v.access_group == "enterprise_admin"
  }
  administrator_users = {
    for k, v in local.hpsj_users_map : k => v if v.access_group == "administrator"
  }
  claims_reviewer_users = {
    for k, v in local.hpsj_users_map : k => v if v.access_group == "claims_reviewer"
  }
  system_view_only_users = {
    for k, v in local.hpsj_users_map : k => v if v.access_group == "system_view_only"
  }
}

resource "okta_group_memberships" "ces_enterprise_admin" {
  group_id = okta_group.ces_enterprise_admin.id
  users    = [for k, _ in local.enterprise_admin_users : okta_user.hpsj[k].id]
}

resource "okta_group_memberships" "ces_administrator" {
  group_id = okta_group.ces_administrator.id
  users    = [for k, _ in local.administrator_users : okta_user.hpsj[k].id]
}

resource "okta_group_memberships" "ces_claims_reviewer" {
  group_id = okta_group.ces_claims_reviewer.id
  users    = [for k, _ in local.claims_reviewer_users : okta_user.hpsj[k].id]
}

resource "okta_group_memberships" "ces_system_view_only" {
  group_id = okta_group.ces_system_view_only.id
  users    = [for k, _ in local.system_view_only_users : okta_user.hpsj[k].id]
}
