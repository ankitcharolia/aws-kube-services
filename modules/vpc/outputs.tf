output "vpc_id" {
  description = "ID of AWS VPC"
  value = aws_vpc.vpc_network.id
}