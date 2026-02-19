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
