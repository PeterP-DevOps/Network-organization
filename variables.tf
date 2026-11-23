variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "admin_cidr" {
  description = "Public IP address allowed to connect via SSH"
  type        = string
}

variable "ubuntu_image_id" {
  description = "Ubuntu 22.04 image ID"
  type        = string
  default     = "fd8nu6v2r30ugg65pb7t"
}

variable "nat_image_id" {
  description = "NAT instance image ID"
  type        = string
  default     = "fd80mrhj8fl2oe87o4e1"
}
