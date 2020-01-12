variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west4"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the puprivate key used for ssh access"
}

variable disk_image {
  description = "Disk image"
}

variable zone {
  description = "Zone"
}

variable "instance_count" {
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
  description = "External loadbalancer port"
}
