output "db_subnet_group_id" {
  description = "The db subnet group name"
  value       = element(concat(aws_db_subnet_group.this.*.id, [""]), 0)
}

output "db_instance_id" {
  value = aws_db_instance.master.id
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.master.address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.master.arn
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = aws_db_instance.master.availability_zone
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.master.endpoint
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = aws_db_instance.master.hosted_zone_id
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of master instance"
  value       = aws_db_instance.master.resource_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value       = aws_db_instance.master.status
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.master.db_name
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.master.username
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.master.port
}

output "db_instance_master_password" {
  description = "The master password"
  value       = aws_db_instance.master.password
  sensitive   = true
}
