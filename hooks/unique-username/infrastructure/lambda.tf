# ---------------------------------------------
# Lambda Function for Unique Username Hook
# ---------------------------------------------
# Ensures unique usernames during Okta user imports
# by appending random suffixes when conflicts are detected

# ---------------------------------------------
# Okta API Token Secret
# ---------------------------------------------

resource "aws_secretsmanager_secret" "okta_api_token" {
  name                    = "${var.project_name}-okta-api-token"
  description             = "Okta API token for unique username Lambda"
  recovery_window_in_days = 0 # For demo - set to 7+ for production

  tags = {
    Name = "${var.project_name}-okta-api-token"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# Note: The actual token value must be set manually:
# aws --profile taskvantage secretsmanager put-secret-value \
#   --secret-id unique-username-hook-okta-api-token \
#   --secret-string "YOUR_OKTA_API_TOKEN"

# ---------------------------------------------
# IAM Role for Lambda
# ---------------------------------------------

resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-lambda-role"
  }
}

# CloudWatch Logs policy
resource "aws_iam_role_policy" "lambda_logging" {
  name = "${var.project_name}-lambda-logging"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.project_name}*"
      }
    ]
  })
}

# Secrets Manager access policy
resource "aws_iam_role_policy" "lambda_secrets" {
  name = "${var.project_name}-lambda-secrets"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.okta_api_token.arn
      }
    ]
  })
}

# ---------------------------------------------
# Lambda Function
# ---------------------------------------------

# Archive the Lambda code
data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda"
  output_path = "${path.module}/../lambda/unique_username.zip"
}

resource "aws_lambda_function" "unique_username" {
  provider      = aws.lambda
  function_name = var.project_name
  description   = "Ensures unique usernames during Okta user imports"

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime     = "python3.12"
  handler     = "handler.handler"
  timeout     = 30
  memory_size = 256

  role = aws_iam_role.lambda.arn

  environment {
    variables = {
      OKTA_ORG_URL          = var.okta_org_url
      OKTA_API_TOKEN_SECRET = aws_secretsmanager_secret.okta_api_token.name
    }
  }

  tags = {
    Name = var.project_name
  }
}

# CloudWatch Log Group (explicit to set retention)
resource "aws_cloudwatch_log_group" "lambda" {
  provider          = aws.lambda
  name              = "/aws/lambda/${aws_lambda_function.unique_username.function_name}"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-logs"
  }
}

# ---------------------------------------------
# API Gateway HTTP API
# ---------------------------------------------

resource "aws_apigatewayv2_api" "hook" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
  description   = "API Gateway for Okta unique username inline hook"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST", "OPTIONS"]
    allow_headers = ["content-type", "x-okta-verification-challenge"]
    max_age       = 300
  }

  tags = {
    Name = "${var.project_name}-api"
  }
}

resource "aws_apigatewayv2_stage" "hook" {
  api_id      = aws_apigatewayv2_api.hook.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Name = "${var.project_name}-stage"
  }
}

resource "aws_apigatewayv2_integration" "hook" {
  api_id                 = aws_apigatewayv2_api.hook.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.unique_username.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "hook" {
  api_id    = aws_apigatewayv2_api.hook.id
  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.hook.id}"
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "apigw" {
  provider      = aws.lambda
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.unique_username.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.hook.execution_arn}/*/*"
}
