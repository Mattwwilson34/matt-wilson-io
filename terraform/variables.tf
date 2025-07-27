variable "do_token" {
  description = "Digital Ocean API Token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/digital_ocean_mattwilson_io_work.pub"
}

variable "domain_name" {
  description = "Your domain name"
  type        = string
  default     = "mattwilson.io"
}

variable "droplet_size" {
  description = "Droplet size - cost controlled"
  type        = string
  default     = "s-1vcpu-512mb-10gb" # $4/month option

  validation {
    condition = contains([
      "s-1vcpu-512mb-10gb", # $4/month  - Basic
    ], var.droplet_size)
    error_message = "Only small droplet sizes allowed for cost control."
  }
}

variable "region" {
  description = "Digital Ocean region"
  type        = string
  default     = "nyc1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "matt-wilson-io"
}
