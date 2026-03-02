variable "okta_org_name" {
  description = "Okta organization name"
  type        = string
  sensitive   = true
}

variable "okta_base_url" {
  description = "Okta base URL (e.g., okta.com or oktapreview.com)"
  type        = string
  default     = "okta.com"
}

variable "okta_api_token" {
  description = "Okta API token"
  type        = string
  sensitive   = true
}

# ---------------------------------------------
# Unique Username Hook Configuration
# ---------------------------------------------

variable "unique_username_hook_enabled" {
  description = "Enable the unique username import hook"
  type        = bool
  default     = true
}

variable "unique_username_hook_url" {
  description = "URL of the unique username Lambda API Gateway endpoint"
  type        = string
  default     = "" # Set after deploying hooks/unique-username/infrastructure
}

variable "hook_auth_token" {
  description = "Bearer token for authenticating Okta hook calls to Lambda"
  type        = string
  sensitive   = true
  default     = "" # Set via GitHub Environment secret or tfvars
}
