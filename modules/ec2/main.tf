###############################################################################
# AWS EC2 Instance Module                                              #
# ----------------------------------------------------------------------------#
# main.tf                                                                     #
###############################################################################

locals {
  yaml_data = yamldecode(file("./etc/ec2.yaml"))
}

# Create additional disk volume for EC2 instance
resource "aws_ebs_volume" "this" {
  for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance if instance.create_extra_disk }

  availability_zone = try(each.value.availability_zone, null)
  size              = try(each.value.storage_disk_size, var.storage_disk_size)
  type              = try(each.value.storage_disk_type, var.storage_disk_type)
  tags              = try(each.value.tags, null)
}