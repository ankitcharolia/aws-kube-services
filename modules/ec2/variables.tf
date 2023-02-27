variable "disk_boot_size" {
  type        = string
  description = "The size in GB of the OS boot volume. (Default: 30GB)"
  default     = "30"
}

variable "create_extra_disk" {
  type        = bool
  description = "True to attach storage disk. False to only have boot disk. (Default: false)"
  default     = false
}

variable "storage_disk_size" {
  type        = string
  description = "The size in GB of the storage volume. (Default: 50)"
  default     = "50"
}

variable "storage_disk_type" {
  type        = string
  description = "AWS EC2 instance disk type (Default: 'gp2')"
  default     = "gp2"
}