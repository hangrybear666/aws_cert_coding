resource "aws_apigatewayv2_api" "aws_api" {
  name          = var.api_name
  description   = var.api_description
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers     = ["content-type"] # other values "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"
    allow_methods     = ["POST"]
    allow_origins     = [var.fqdn]
    allow_credentials = false # For sending cookies or credentials
    expose_headers    = [] # Headers exposed to the browser. check allow_headers for values
    max_age           = 3600 # Cache CORS preflight response for 1 hour
  }
}

resource "aws_apigatewayv2_integration" "upload_img" {
  api_id           = aws_apigatewayv2_api.aws_api.id
  integration_type = "AWS_PROXY"

  connection_type           = "INTERNET"
  description               = "Lambda Upload Image Integration"
  integration_method        = "POST"
  integration_uri           = var.lambda_invoke_arn_upload_img
}

# Integration with a Lambda function
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name_upload_img
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.aws_api.execution_arn}/*"
}

resource "aws_apigatewayv2_route" "upload_img" {
  api_id    = aws_apigatewayv2_api.aws_api.id
  route_key = "POST /aws_api/fiscalismia/upload/food_item_img"
  target    = "integrations/${aws_apigatewayv2_integration.upload_img.id}"
  depends_on = [aws_apigatewayv2_integration.upload_img]
}

# Default stage. Stages allow multi environment deploys like dev prod stage
resource "aws_apigatewayv2_stage" "main_stage_route_config" {
  api_id      = aws_apigatewayv2_api.aws_api.id
  name        = "default"
  description = "Default stage for Fiscalismia API"
  default_route_settings {
    throttling_burst_limit = 5    # Max burst of 5 requests
    throttling_rate_limit  = 2.0  # Sustained rate of 2 requests per second
  }
  route_settings {
    route_key             = "POST /aws_api/fiscalismia/upload/food_item_img"
    throttling_burst_limit = 5
    throttling_rate_limit  = 2.0
  }
  auto_deploy = true
  depends_on = [aws_apigatewayv2_route.upload_img]
}

