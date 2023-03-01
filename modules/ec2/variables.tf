variable "subnet_id" {
  type        = string
  description = "VPC Subnet ID the instance is launched in"
}

variable "create_extra_disk" {
  type        = bool
  description = "True to attach storage disk. False to only have boot disk. (Default: false)"
  default     = false
}

variable "boot_disk_size" {
  type        = string
  description = "The size in GB of the OS boot volume. (Default: 30GB)"
  default     = "30"
}

variable "storage_disk_size" {
  type        = string
  description = "The size in GB of the storage volume. (Default: 50GB)"
  default     = "50"
}

variable "storage_disk_type" {
  type        = string
  description = "AWS EC2 instance disk type (Default: 'gp2')"
  default     = "gp2"
}

variable "ssh_key_pair" {
  type        = string
  description = "SSH key pair to be provisioned on the instance"
  default     = null
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address with the instance"
  default     = false
}

variable "assign_eip_address" {
  type        = bool
  description = "Assign an Elastic IP address to the instance"
  default     = true
}

variable "user_data" {
  type        = string
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; use `user_data_base64` instead"
  default     = null
}

variable "user_data_base64" {
  type        = string
  description = "Can be used instead of `user_data` to pass base64-encoded binary data directly. Use this instead of `user_data` whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption"
  default     = null
}

variable "instance_type" {
  type        = string
  description = "The type of the instance"
  default     = "t2.micro"
}

variable "burstable_mode" {
  type        = string
  description = "Enable burstable mode for the instance. Can be standard or unlimited. Applicable only for T2/T3/T4g instance types."
  default     = null
}

variable "security_group_enabled" {
  type        = bool
  description = "Whether to create default Security Group for EC2."
  default     = true
}

variable "security_groups" {
  description = "A list of Security Group IDs to associate with EC2 instance."
  type        = list(string)
  default     = []
}

variable "root_block_device_encrypted" {
  type        = bool
  description = "Whether to encrypt the root block device"
  default     = false
}

variable "root_block_device_kms_key_id" {
  type        = string
  description = "KMS key ID used to encrypt EBS volume. When specifying root_block_device_kms_key_id, root_block_device_encrypted needs to be set to true"
  default     = null
}

variable "root_volume_type" {
  type        = string
  description = "Type of root volume. Can be standard, gp2, gp3, io1 or io2"
  default     = "gp2"
}

variable "root_volume_size" {
  type        = number
  description = "Size of the root volume in gigabytes"
  default     = 20
}

variable "ebs_volume_encrypted" {
  type        = bool
  description = "Whether to encrypt the additional EBS volumes"
  default     = false
}

variable "monitoring" {
  type        = bool
  description = "Launched EC2 instance will have detailed monitoring enabled"
  default     = true
}

variable "disable_api_termination" {
  type        = bool
  description = "Enable EC2 Instance Termination Protection"
  default     = false
}

variable "delete_on_termination" {
  type        = bool
  description = "Whether the volume should be destroyed on instance termination"
  default     = true
}

