variable "domain_name" {
  description = "Your purchased domain name"
  type        = string
}
variable "alb_arn" {
  description   = "Amazon Resource Name of your Application Load Balancer"
  type          = string
}
variable "resource_prefix" {
  description   = "Prefix for Name Tags"
  type          = string
  default       = "fiscalismia"
}
variable "subdomain_list" {
  description   = "List of subdomains to register for main domain, e.g. ['api', 'demo']"
  type          = list(string)
}