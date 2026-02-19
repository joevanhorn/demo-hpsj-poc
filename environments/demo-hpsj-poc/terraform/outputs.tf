output "optum_ces_app_id" {
  description = "Optum CES Generic DB Connector app ID"
  value       = local.optum_ces_app_id
}

output "ces_group_ids" {
  description = "CES access group IDs"
  value = {
    enterprise_admin = okta_group.ces_enterprise_admin.id
    administrator    = okta_group.ces_administrator.id
    claims_reviewer  = okta_group.ces_claims_reviewer.id
    system_view_only = okta_group.ces_system_view_only.id
  }
}

output "department_group_ids" {
  description = "Department group IDs"
  value = { for k, v in okta_group.departments : k => v.id }
}

output "user_count" {
  description = "Number of HPSJ demo users created"
  value       = length(okta_user.hpsj)
}
