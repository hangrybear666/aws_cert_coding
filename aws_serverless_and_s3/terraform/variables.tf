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