variable "public_key_path" {
  type        = string
  description = "Path to the public key used for ssh access"
}

variable "zone" {
  type        = string
  description = "Zone"
}

variable "app_disk_image" {
  description = "Disk image for reddit app"
  default     = "reddit-app"
}

variable "machine_type" {
  type        = string
  description = "Type of creating machine"
  default     = "f1-micro"
}

variable "private_key_path" {
  type        = string
  description = "Path to the puprivate key used for ssh access"
}

variable "deploy" {
  type        = bool
  description = "Enable provisioners"
}

variable "db_addr" {
  type        = string
  description = "Database IP address"
}
