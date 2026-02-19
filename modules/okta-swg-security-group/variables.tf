variable "name" {
  description = "Name for the security group"
  type        = string
  default     = "Okta-SWG-All-US"
}

variable "description" {
  description = "Description for the security group"
  type        = string
  default     = "Allows access from all Okta US SWG subnets"
}

variable "vpc_id" {
  description = "VPC ID to create the security group in"
  type        = string
}

variable "prefix_list_names" {
  description = "Okta SWG managed prefix list names to include"
  type        = list(string)
  default = [
    "bt-okta-swg-us-central-v1",
    "bt-okta-swg-us-northwest-v1",
    "bt-okta-swg-us-northeast-v1",
    "bt-okta-swg-us-southeast-v1",
    "bt-okta-swg-us-southwest-v1",
    "bt-okta-swg-us-central-west-v1",
    "bt-okta-swg-us-south-v1",
    "bt-okta-swg-us-east-v1",
    "bt-okta-swg-us-west-v1",
  ]
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
