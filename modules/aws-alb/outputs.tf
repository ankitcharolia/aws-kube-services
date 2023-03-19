###############################################
## Application Load Balancer Module - Output ##
###############################################

output "alb_dns_name" {
  description = "DNS Name of Linux application load balancer"
  value = toset([
    for key, value in aws_lb.alb : {
      (key) : {
        "dns_name" = value.dns_name
      }
    }
  ])
}