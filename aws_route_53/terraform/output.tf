output "tls_certificate" {
  description = "TLS Cert for root domain including all subdomains via *.domain.top_level_domain"
  value = module.dns_tls.tls_certificate
}