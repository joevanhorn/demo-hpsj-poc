# ==============================================================================
# UNIQUE USERNAME IMPORT HOOK
# ==============================================================================
# User Import Inline Hook that guarantees unique username generation.
#
# When a user is imported and their login already exists in Okta, this hook
# appends a random 4-character suffix to create a unique login:
#   john.doe@example.com -> john.doe.x7k2@example.com
#
# Architecture:
#   Okta Import -> API Gateway -> Lambda -> Okta Users API (conflict check)
#
# Prerequisites:
#   1. Deploy hooks/unique-username/infrastructure (Lambda + API Gateway)
#   2. Set unique_username_hook_url to the API Gateway endpoint
#   3. Set hook_auth_token for authentication
# ==============================================================================

# ==============================================================================
# INLINE HOOK
# ==============================================================================

resource "okta_inline_hook" "unique_username" {
  count = var.unique_username_hook_enabled && var.unique_username_hook_url != "" ? 1 : 0

  name    = "Unique Username Generator"
  type    = "com.okta.import.transform"
  version = "1.0.0"
  status  = "ACTIVE"

  channel = {
    type    = "HTTP"
    version = "1.0.0"
    uri     = var.unique_username_hook_url
    method  = "POST"
  }

  auth = {
    type  = "HEADER"
    key   = "Authorization"
    value = var.hook_auth_token != "" ? "Bearer ${var.hook_auth_token}" : "Bearer placeholder"
  }
}

# ==============================================================================
# OUTPUTS
# ==============================================================================

output "unique_username_hook_id" {
  description = "ID of the Unique Username inline hook"
  value       = length(okta_inline_hook.unique_username) > 0 ? okta_inline_hook.unique_username[0].id : null
}

output "unique_username_hook_name" {
  description = "Name of the Unique Username inline hook"
  value       = length(okta_inline_hook.unique_username) > 0 ? okta_inline_hook.unique_username[0].name : null
}
