output "security_group_id" {
  description = "ID of the Okta SWG security group"
  value       = aws_security_group.okta_swg.id
}

output "security_group_name" {
  description = "Name of the Okta SWG security group"
  value       = aws_security_group.okta_swg.name
}
