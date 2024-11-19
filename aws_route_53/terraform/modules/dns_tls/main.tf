#  ___       __      __   ___  __  ___    ___    __       ___  ___
#   |  |    /__`    /  ` |__  |__)  |  | |__  | /  `  /\   |  |__
#   |  |___ .__/    \__, |___ |  \  |  | |    | \__, /~~\  |  |___
resource "aws_acm_certificate" "my_tls_cert" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]

  validation_method = "DNS"

  lifecycle {
    # the new replacement object is created first, and the prior object is destroyed after the replacement is created.
    create_before_destroy = true
  }
  tags = {
    Name = "${var.resource_prefix}-acm-cert"
  }
}

resource "aws_acm_certificate_validation" "cert_validation" {
  timeouts {
    create = "3m"
  }
  certificate_arn         = aws_acm_certificate.my_tls_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}

resource "aws_route53_record" "cert_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.my_tls_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected_zone.zone_id
}

#   __        __      __   ___  __   __   __   __   __
#  |  \ |\ | /__`    |__) |__  /  ` /  \ |__) |  \ /__`
#  |__/ | \| .__/    |  \ |___ \__, \__/ |  \ |__/ .__/
resource "aws_route53_record" "type_A_root_domain" {
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = data.aws_lb.alb_https_terminator.dns_name
    zone_id                = data.aws_lb.alb_https_terminator.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "type_A_subdomains" {
  for_each = toset(var.subdomain_list)
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = "${each.value}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = data.aws_lb.alb_https_terminator.dns_name
    zone_id                = data.aws_lb.alb_https_terminator.zone_id
    evaluate_target_health = true
  }
}

#        ___           ___          __        ___  __
#  |__| |__   /\  |     |  |__|    /  ` |__| |__  /  ` |__/
#  |  | |___ /~~\ |___  |  |  |    \__, |  | |___ \__, |  \
resource "aws_route53_health_check" "root_domain_https_reachable" {
  fqdn              = var.domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/"
  failure_threshold = "5"
  request_interval  = "30"

  tags = {
    Name = "${var.resource_prefix}-health-check"
  }
}