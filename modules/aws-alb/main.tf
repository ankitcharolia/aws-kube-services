#############################################
## Application Load Balancer Module - Main ##
#############################################

locals {
  yaml_data = yamldecode(file("./etc/lb.yaml"))

  listeners = flatten([for alb in local.yaml_data.application_loadbalancers : [
    for listener in try(alb.listeners, []) : {
      name      = alb.name
      port      = listener.port 
      type      = listener.type
      protocol  = listener.protocol
      }
    ]
  ])

  # target_groups = flatten([for alb in local.yaml_data.application_loadbalancers : [
  #   for target_group in try(alb.target_groups, []) : {
  #     lb_name           = alb.name
  #     target_name       = target_group.name
  #     target_port       = target_group.port 
  #     target_path       = target_group.path
  #     target_protocol   = target_group.protocol
  #     }
  #   ]
  # ])

  target_groups = flatten([for alb in local.yaml_data.application_loadbalancers : [
    for target_group in try(alb.target_groups, []) : [
      for target_instance in try(target_group.target_instances, []) : {
          lb_name           = alb.name
          target_name       = target_group.name
          target_port       = target_group.port 
          target_path       = target_group.path
          target_protocol   = target_group.protocol
          target_instance   = target_instance
        }
      ]]
    ])

}

# Create a Security Group for The Load Balancer
resource "aws_security_group" "alb-sg" {
  for_each = { for alb in local.yaml_data.application_loadbalancers : alb.name => alb }

  name        = "${each.value.name}-alb-sg"
  description = "Allow web traffic to the load balancer"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${each.value.name}-alb-sg"
  }
}

# Create an Application Load Balancer
resource "aws_lb" "alb" {
  for_each = { for alb in local.yaml_data.application_loadbalancers : alb.name => alb }

  name               = "${each.value.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg[each.key].id]
  subnets            = var.subnets

  enable_deletion_protection = try(each.value.enable_deletion_protection, false)
  enable_http2               = false

  dynamic "access_logs" {
    for_each = try(each.value.access_logs_enabled, false) ? [1] : []
    content {
      bucket  = var.bucket
      prefix  = "test-lb"
      enabled = true
    }
  }

  tags = {
    Name        = "${each.value.name}-alb"
  }
}

# Create a Load Balancer Target Group
resource "aws_lb_target_group" "alb-target-group" {  
  for_each =  { for idx, record in local.target_groups : idx => record }

  name     = "${each.value.target_name}-alb-tg"
  port     = each.value.target_port
  protocol = each.value.target_protocol
  vpc_id   = var.vpc_id
  
  deregistration_delay = 60

  stickiness {
    type            = "lb_cookie"
    enabled         = true
    cookie_duration = 86400
  }

  health_check {
    enabled             = true
    path                = try(each.value.target_path, "/")
    port                = each.value.target_port
    # Number of consecutive health check successes required before considering a target healthy
    healthy_threshold   = 3
    # Number of consecutive health check failures required before considering a target unhealthy.
    unhealthy_threshold = 3
    timeout             = 10
    # amount of time, in seconds, between health checks 
    interval            = 30
    matcher             = "200,301,302"
  }
}


data "aws_instance" "this" {
  for_each =  { for idx, record in local.target_groups : idx => record }

  filter {
    name = "tag:Name"
    values = [each.value.target_instance]
  }
}

# Attach EC2 Instances to Application Load Balancer Target Group
resource "aws_alb_target_group_attachment" "alb-target-group-attach" {
  for_each =  { for idx, record in local.target_groups : idx => record }

  target_group_arn = aws_lb_target_group.alb-target-group[each.key].arn
  target_id        = data.aws_instance.this[each.key].id
  port             = each.value.target_port
}

# Create the Application Load Balancer Listener
resource "aws_lb_listener" "alb-listener" {  
  for_each =  { for idx, record in local.listeners : idx => record }
  
  load_balancer_arn = aws_lb.alb[each.value.name].arn
  port              = each.value.port
  protocol          = each.value.protocol
  
  default_action {
    target_group_arn = aws_lb_target_group.alb-target-group[each.key].arn
    type             = each.value.type  
  }

  depends_on = [
    aws_lb.alb,
    aws_lb_target_group.alb-target-group
  ]
}

# # ######################################

# # Reference to the AWS Route53 Public Zone
# data "aws_route53_zone" "public-zone" {
#   name         = var.public_dns_name
#   private_zone = false
# }

# # Create AWS Route53 A Record for the Load Balancer
# resource "aws_route53_record" "linux-alb-a-record" {
#   depends_on = [aws_lb.linux-alb]

#   zone_id = data.aws_route53_zone.public-zone.zone_id
#   name    = "${var.dns_hostname}.${var.public_dns_name}"
#   type    = "A"

#   alias {
#     name                   = aws_lb.linux-alb.dns_name
#     zone_id                = aws_lb.linux-alb.zone_id
#     evaluate_target_health = true
#   }
# }

# # ######################################

# # Create Certificate
# resource "aws_acm_certificate" "linux-alb-certificate" {
#   domain_name       = "${var.dns_hostname}.${var.public_dns_name}"
#   validation_method = "DNS"
  
#   tags = {
#     Name        = "${lower(var.app_name)}-${var.app_environment}-linux-alb-certificate"
#   }
# }

# # Create AWS Route 53 Certificate Validation Record
# resource "aws_route53_record" "linux-alb-certificate-validation-record" {
#   for_each = {
#     for dvo in aws_acm_certificate.linux-alb-certificate.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.public-zone.zone_id
# }

# # Create Certificate Validation
# resource "aws_acm_certificate_validation" "linux-certificate-validation" {
#   certificate_arn         = aws_acm_certificate.linux-alb-certificate.arn
#   validation_record_fqdns = [for record in aws_route53_record.linux-alb-certificate-validation-record : record.fqdn]
# }

# # ######################################

# # Create Application Load Balancer Listener for HTTPS
# resource "aws_alb_listener" "linux-alb-listener-https" {
#   depends_on = [aws_acm_certificate.linux-alb-certificate]

#   load_balancer_arn = aws_lb.linux-alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = aws_acm_certificate.linux-alb-certificate.arn

#   default_action {
#     target_group_arn = aws_lb_target_group.linux-alb-target-group-http.arn
#     type = "forward"
#   }
# }