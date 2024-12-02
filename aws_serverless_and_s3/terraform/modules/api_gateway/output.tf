output "aws_api" {
  value = aws_apigatewayv2_api.aws_api
}
output "route_post_food_item_img" {
  value = aws_apigatewayv2_route.upload_img
}