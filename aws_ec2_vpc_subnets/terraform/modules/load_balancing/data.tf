data "aws_acm_certificate" "my_tls_cert" {
  domain      = var.domain_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}