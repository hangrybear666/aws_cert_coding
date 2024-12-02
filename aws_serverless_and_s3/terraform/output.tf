output "http_aws_api_endpoint" {
  description = "The http api endpoint"
  value = module.api_gateway.aws_api.api_endpoint
}
output "http_aws_api_arn" {
  description = "The http api arn"
  value = module.api_gateway.aws_api.arn
}
output "http_aws_api_execution_arn" {
  description = "The http api execution arn"
  value = module.api_gateway.aws_api.execution_arn
}

output "http_aws_api_route_selection_expression" {
  description = "The http route expression"
  value = module.api_gateway.aws_api.route_selection_expression
}

