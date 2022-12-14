output "ingress_nginx_external_ip" {
  description = "External IP of Ingress Nginx Controller"
  value       = one(data.kubernetes_service.nginx_ingress_controller.status.0.load_balancer.0.ingress[*].ip)
}
