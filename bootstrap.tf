# Providers
provider "cloudflare" {
  api_token = var.cloudflare_token
}
provider "hcloud" {
  token = var.hcloud_token
}

provider "random" {
}

variable "hcloud_token" {
  sensitive = true
}

# Hetzner variables
variable "name" {
  description = "The name of the server."
  type        = string
}
variable "location" {
  default = "fsn1"
  type    = string
}

variable "server_type" {
  default = "cx11"
  type    = string
}

variable "image" {
  default = "ubuntu-20.04"
  type    = string
}

# Cloudflare Variables
variable "domain" {
  description = "The domain the server will be accessible from."
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The Cloudflare UUID for the Zone to use."
  type        = string
}

variable "cloudflare_account_id" {
  description = "The Cloudflare UUID for the Account the Zone lives in."
  type        = string
  sensitive   = true
}

variable "cloudflare_email" {
  description = "The Cloudflare user."
  type        = string
  sensitive   = true
}

variable "cloudflare_token" {
  description = "The Cloudflare user's API token."
  type        = string
}

output "unix_password" {
  value     = random_password.unix_password.result
  sensitive = true
}