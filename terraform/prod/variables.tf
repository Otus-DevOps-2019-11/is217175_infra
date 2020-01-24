variable "project" {
  type        = string
  description = "Project ID"
}

variable "region" {
  type        = string
  description = "Region"
  default     = "europe-west4"
}

variable "public_key_path" {
  type        = string
  description = "Path to the public key used for ssh access"
}

variable "private_key_path" {
  type        = string
  description = "Path to the puprivate key used for ssh access"
}

variable "disk_image" {
  type        = string
  description = "Disk image"
}

variable "zone" {
  type        = string
  description = "Zone"
}

variable "instance_count" {
  type        = number
  description = "Count of created compute instances"
  default     = 1
}

variable "app_named_port" {
  type = object({
    name = string
    port = number
  })
  description = "Application named port"
}

variable "external_port" {
  type        = number
  description = "External loadbalancer port"
}

variable "app_disk_image" {
  description = "Disk image for reddit app"
  default     = "reddit-app"
}

variable "db_disk_image" {
  description = "Disk image for reddit app"
  default     = "reddit-db"
}

variable "deploy" {
  type        = bool
  description = "Enable provisioners"
}
