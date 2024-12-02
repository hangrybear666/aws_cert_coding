variable "fqdn" {
  default = "https://fiscalismia.com"
  description = "fully qualified domain name of source webservice for CORS access"
  type = string
}
variable "service_name" {
  default = "fiscalismia"
  description = "webservice name for resource naming"
  type = string
}
variable "default_stage" {
  default = "api"
  description = "HTTP API can be separated into stages that change the endpoint routes to start with /stage/"
}
variable "post_food_item_img_route" {
  default = "/fiscalismia/upload/food_item_img"
  description = "http api route for aws. the default stage is prepended."
}