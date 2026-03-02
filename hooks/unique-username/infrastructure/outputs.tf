# Outputs for Unique Username Hook Infrastructure

output "lambda_arn" {
  description = "ARN of the unique username Lambda function"
  value       = aws_lambda_function.unique_username.arn
}

output "hook_url" {
  description = "Public URL of the API Gateway (use for Okta inline hook)"
  value       = aws_apigatewayv2_api.hook.api_endpoint
}

output "okta_token_secret_name" {
  description = "Name of the Secrets Manager secret for Okta API token"
  value       = aws_secretsmanager_secret.okta_api_token.name
}

output "setup_instructions" {
  description = "Instructions to complete setup"
  value       = <<-EOT

    Unique Username Hook Setup:
    ===========================

    1. Set the Okta API token in Secrets Manager:
       aws secretsmanager put-secret-value \
         --secret-id ${aws_secretsmanager_secret.okta_api_token.name} \
         --secret-string "YOUR_OKTA_API_TOKEN"

    2. The inline hook endpoint URL is:
       ${aws_apigatewayv2_api.hook.api_endpoint}

    3. Test the Lambda:
       curl -X POST ${aws_apigatewayv2_api.hook.api_endpoint} \
         -H "Content-Type: application/json" \
         -d '{"data":{"appUser":{"profile":{"login":"test@example.com","email":"test@example.com"}}}}'

    4. Register the hook in Okta (via Terraform in the environment directory)
       or manually in Admin Console > Workflow > Inline Hooks.
  EOT
}
