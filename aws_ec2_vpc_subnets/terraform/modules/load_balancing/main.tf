#             __
#   /\  |    |__)
#  /~~\ |___ |__)
resource "aws_lb" "alb_for_private_ec2s" {
  name               = "alb-for-private-ec2s"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2_alb_sg.id]
  subnets            = [for subnet in var.aws_subnets : subnet.id]

  enable_deletion_protection = false

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "alb-to-ec2"
  #   enabled = true
  # }

  tags = {
    Name = "${var.env_prefix}-alb-ec2"
  }
}

#          __  ___  ___       ___  __
#  |    | /__`  |  |__  |\ | |__  |__)
#  |___ | .__/  |  |___ | \| |___ |  \
resource "aws_lb_listener" "https_for_private_ec2_instances" {
  load_balancer_arn = aws_lb.alb_for_private_ec2s.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   =  data.aws_acm_certificate.my_tls_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_to_private_ec2s.arn
  }
  tags = {
    Name = "${var.env_prefix}-alb-ec2-https"
  }
}

resource "aws_lb_listener" "http_redirect_to_https" {
  load_balancer_arn = aws_lb.alb_for_private_ec2s.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = {
    Name = "${var.env_prefix}-alb-ec2-http-redirect"
  }
}

# Rule to handle /favicon.ico specifically
resource "aws_alb_listener_rule" "https_forward_favicon" {
  listener_arn = aws_lb_listener.https_for_private_ec2_instances.arn
  priority     = 1 # Higher priority than the redirect rule

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_to_private_ec2s.arn
  }

  condition {
    path_pattern {
      values = ["/favicon.ico", "/"] # prevents redirecting the favicon and the root path as both are matched by https_redirect_to_root_path
    }
  }
}

resource "aws_alb_listener_rule" "https_redirect_to_root_path" {
  listener_arn = aws_lb_listener.https_for_private_ec2_instances.arn
  priority     = 2 # Lower priority

  action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
      path        = "/" # Redirect to the root path
    }
  }

  condition {
    path_pattern {
      values = ["/*"] # Matches all paths
    }
  }
}

#  ___       __   __   ___ ___      __   __   __        __
#   |   /\  |__) / _` |__   |      / _` |__) /  \ |  | |__)
#   |  /~~\ |  \ \__> |___  |  ___ \__> |  \ \__/ \__/ |
resource "aws_lb_target_group" "alb_to_private_ec2s" {
  name     = "ec2-alb-http-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.aws_vpc.id

  health_check {
    path = "/"
    protocol = "HTTP"
    port = 80
    healthy_threshold = 3 # number of consecutive successes for  healthy   status
    unhealthy_threshold = 2 # number of consecutive failures for unhealthy status
    timeout = 10 # number of seconds without response after which it is a failure
    interval = 30 # number of seconds between health checks
    matcher = "200"  # has to be HTTP status 200 or fails
  }

  tags = {
    Name = "${var.env_prefix}-alb-ec2-http-tg"
  }
}

resource "aws_lb_target_group_attachment" "alb_to_private_ec2" {
  # convert a list of instance objects to a map with instance ID as the key, and an instance
  # object as the value.
  for_each = {
    for k, v in var.ec2_instances :
    k => v
  }

  target_group_arn = aws_lb_target_group.alb_to_private_ec2s.arn
  target_id        = each.value.id
  port             = 80
}