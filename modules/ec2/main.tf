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

# TODO
# Attach additional disk to instance, so that we can move this volume to another instance if needed later.
# This will appear at /dev/disk/by-id/-{NAME}
resource "aws_volume_attachment" "this" {
  for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance if instance.create_extra_disk }

  device_name                       = "/dev/sdb"
  volume_id                         = try(each.value.create_extra_disk ? aws_ebs_volume.this[each.key].id : null, null)
  instance_id                       = try(each.value.create_extra_disk ? aws_instance.this[each.key].id : null, null)
  stop_instance_before_detaching    = true
}

resource "aws_network_interface" "this" {
  for_each  = { for instance in local.yaml_data.ec2_instances : instance.name => instance if instance.create_extra_disk }

  subnet_id = var.subnet_id
  tags      = try(each.value.tags, null)
}

resource "aws_network_interface_attachment" "this" {
  for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance if instance.create_extra_disk }

  instance_id          = aws_instance.this[each.key].id
  network_interface_id = aws_network_interface.this[each.key].id
  device_index         = 0
}

# Create an  IP for the instance
resource "aws_eip" "this" {

  vpc               = true
  network_interface = aws_network_interface.this[count.index].id
}
