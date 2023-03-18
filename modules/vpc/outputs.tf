output "vpc_id" {
  description = "ID of AWS VPC"
  value = aws_vpc.vpc_network.id
}

output "private_subnet_id" {
  description = "ID of AWS Private Subnet"
  value = aws_subnet.private_subnets[*].id
}

output "public_subnet_id" {
  description = "ID of AWS Public Subnet"
  value = aws_subnet.public_subnets[*].id
}

output "istio_ingressgateway_loadbalancer_ip" {
  value = aws_eip.istio_ingress_controller.public_ip
}