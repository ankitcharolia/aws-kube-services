###############################################################################
# AWS EC2 Instance Module                                              #
# ----------------------------------------------------------------------------#
# main.tf                                                                     #
###############################################################################

locals {
  yaml_data = yamldecode(file("./etc/ec2.yaml"))

  inbound_rules = flatten([for instance in local.yaml_data.ec2_instances : [
    for inbound_rule in try(instance.sg_inbound_rules, []) : {
      name        = instance.name
      from_port   = inbound_rule.port
      to_port     = inbound_rule.port
      protocol    = inbound_rule.protocol
      cidr_blocks = inbound_rule.cidr_blocks
    }
    ]
  ])

  outbound_rules = flatten([for instance in local.yaml_data.ec2_instances : [
    for outbound_rule in try(instance.sg_outbound_rules, []) : {
      name        = instance.name
      from_port   = try(outbound_rule.port, 0)
      to_port     = try(outbound_rule.port, 0)
      protocol    = try(outbound_rule.protocol, -1)
      cidr_blocks = try(outbound_rule.cidr_blocks, ["0.0.0.0/0"])
    }
    ]
  ])
}

resource "aws_security_group" "this" {
  for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance }

  name        = "${each.value.name}-sg"
  description = "${each.value.name}-security-group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${each.value.name}-sg"
  }
}

resource "aws_security_group_rule" "ingress" {
  for_each = { for idx, record in local.inbound_rules : idx => record }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = try(each.value.cidr_blocks, null)
  security_group_id = aws_security_group.this[each.value.name].id
  # source_security_group_id and cidr_blocks can not be specified together
  source_security_group_id = try(each.value.source_security_group_id, null)
}

resource "aws_security_group_rule" "egress" {
  for_each = { for idx, record in local.outbound_rules : idx => record }

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.from_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_security_group.this[each.value.name].id
}

# Create additional disk volume for EC2 instance
resource "aws_ebs_volume" "this" {
  for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance if try(instance.create_extra_disk, false) }

  availability_zone = try(each.value.availability_zone, null)
  size              = try(each.value.storage_disk_size, var.storage_disk_size)
  type              = try(each.value.storage_disk_type, var.storage_disk_type)
  encrypted         = var.ebs_volume_encrypted
  tags = {
    "Name" = "${each.value.name}-data-disk"
  }
}

# Attach additional disk to instance, so that we can move this volume to another instance if needed later.
# Linux kernels may rename your devices to /dev/xvdf through /dev/xvdp internally, even when the device name is /dev/sdf 
resource "aws_volume_attachment" "this" {
  for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance if try(instance.create_extra_disk, false) }

  device_name                    = "/dev/sdb"
  volume_id                      = try(each.value.create_extra_disk ? aws_ebs_volume.this[each.key].id : null, null)
  instance_id                    = try(each.value.create_extra_disk ? aws_instance.this[each.key].id : null, null)
  stop_instance_before_detaching = true
}

# Add the additional network interface to the VM
resource "aws_network_interface" "this" {
  for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance }

  description = "Primary Network Interface for ${each.value.name}"
  subnet_id   = var.subnet_id
  # security_groups are assigned to network interfaces, no instance
  security_groups = try([aws_security_group.this[each.value.name].id], null)
  tags = merge(try(each.value.tags, null), {
    Name = "${each.value.name}"
  })
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

# resource "random_shuffle" "subnet" {
#   for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance }

#   input        = [module.aws_vpc.public_subnet_id[0], module.aws_vpc.public_subnet_id[1]]
#   result_count = 1
# }

# Create a Amazon EC2 instance
resource "aws_instance" "this" {
  for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance }

  ami                     = try(each.value.ami_id, data.aws_ami.this.id)
  instance_type           = try(each.value.instance_type, var.instance_type)
  availability_zone       = each.value.availability_zone
  disable_api_termination = try(each.value.disable_api_termination, var.disable_api_termination)
  monitoring              = try(each.value.monitoring, var.monitoring)
  key_name                = var.ssh_key_pair
  user_data               = file("./etc/cloud-init/initialize.sh")

  # vpc_security_group_ids      = try([aws_security_group.this[each.value.name].id], null)

  root_block_device {
    volume_type           = try(each.value.root_volume_type, var.root_volume_type)
    volume_size           = try(each.value.root_volume_size, var.root_volume_size)
    delete_on_termination = var.delete_on_termination
    encrypted             = var.root_block_device_encrypted
    kms_key_id            = var.root_block_device_kms_key_id
    tags = {
      Name = "${each.value.name}-root-disk"
    }
  }

  network_interface {
    network_interface_id = aws_network_interface.this[each.key].id
    device_index         = 0
  }

  metadata_options {
    http_endpoint               = var.metadata_http_endpoint_enabled ? "enabled" : "disabled"
    instance_metadata_tags      = var.metadata_tags_enabled ? "enabled" : "disabled"
    http_put_response_hop_limit = var.metadata_http_put_response_hop_limit
    http_tokens                 = var.metadata_http_tokens_required ? "required" : "optional"
  }

  # don't force-recreate instance if only user data changes
  lifecycle {
    ignore_changes = [
      user_data,
    ]
  }

  tags = merge(try(each.value.tags, null), {
    Name              = "${each.value.name}.${var.dns_name}"
    create_extra_disk = try(each.value.create_extra_disk, false)
    mount_dir         = try(each.value.mount_dir, "/var/opt")
  })

}

# Create an Elastic IP for the instance
# when map_public_ip_on_launch is true in VPC public subnet , the instance will automatically get public IP.
# this resource is useless when map_public_ip_on_launch is true
resource "aws_eip" "this" {
  for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance if try(instance.assign_eip, false) }

  vpc      = true
  instance = aws_instance.this[each.key].id
  tags     = try(each.value.tags, null)
  depends_on = [
    aws_instance.this,
  ]
}

resource "aws_ec2_instance_state" "this" {
  for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance }

  instance_id = aws_instance.this[each.key].id
  state       = try(each.value.instance_state, "running")
}

# Create a DNS record
resource "aws_route53_record" "a_record" {
  for_each = { for instance in local.yaml_data.ec2_instances : instance.name => instance }

  zone_id = var.zone_id
  name    = "${each.value.name}.${var.dns_name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.this[each.key].private_ip]
}
