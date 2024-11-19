provider "aws" {}

module "dns_tls" {
  source = "./modules/dns_tls"
  domain_name = var.domain_name
  subdomain_list = var.subdomain_list
  resource_prefix = var.resource_prefix
  alb_arn = var.alb_arn
}
