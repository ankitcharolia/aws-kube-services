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
  encrypted         = var.ebs_volume_encrypted
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

# Create the primary network interface to the VM
resource "aws_network_interface" "this" {
  for_each  = { for instance in local.yaml_data.ec2_instances : instance.name => instance }

  description = "Primary Network Interface for ${each.value.name}"
  subnet_id = var.subnet_id
  tags      = try(each.value.tags, null)
}

# Attach the primary network interface to the VM
resource "aws_network_interface_attachment" "this" {
  for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance }

  instance_id          = aws_instance.this[each.key].id
  network_interface_id = aws_network_interface.this[each.key].id
  device_index         = 0

  depends_on = [
    aws_instance.this,
    aws_network_interface.this,
  ]
}

data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Create a Amazon EC2 instance
resource "aws_instance" "this" {
  for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance }

  ami                         = try(each.value.ami_id, data.aws_ami.this.id)
  instance_type               = try(each.value.instance_type, var.instance_type)
  availability_zone           = each.value.availability_zone
  disable_api_termination     = try(each.value.disable_api_termination, var.disable_api_termination)
  associate_public_ip_address = try(each.value.associate_public_ip_address, var.associate_public_ip_address)
  monitoring                  = try(each.value.monitoring, var.monitoring)
  subnet_id                   = var.subnet_id

  root_block_device {
    volume_type           = try(each.value.root_volume_type ,var.root_volume_type)
    volume_size           = try(each.value.root_volume_size ,var.root_volume_size)
    delete_on_termination = var.delete_on_termination
    encrypted             = var.root_block_device_encrypted
    kms_key_id            = var.root_block_device_kms_key_id
  }

  # don't force-recreate instance if only user data changes
  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }

  tags      = try(each.value.tags, null)

}

# Create an Elastic IP for the instance
resource "aws_eip" "this" {
  for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance if try(instance.associate_public_ip_address, false) }

  vpc         = true
  instance    = aws_instance.this[each.key].id
  tags        = try(each.value.tags, null)
  depends_on  = [
    aws_instance.this,
  ]
}