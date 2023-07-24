# Cloudflare Variables
variable "hostname" {
  description = "The hostname the server will be accessible from."
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

variable "r2_bucket" {
  description = "The R2 bucket to store the Terraform state in."
  type        = string
}

variable "r2_endpoint" {
  description = "The R2 endpoint to store the Terraform state in."
  type        = string
}

variable "r2_access_key" {
  description = "The R2 access key to store the Terraform state in."
  type        = string
  sensitive   = true
}

variable "r2_secret_key" {
  description = "The R2 secret key to store the Terraform state in."
  type        = string
  sensitive   = true
}

# Hetzner variables
variable "hcloud_token" {
  description = "The Hetzner Cloud API token."
  type        = string
  sensitive   = true
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
  default = "ubuntu-22.04"
  type    = string
}

# Github variables
variable "github_token" {
  description = "The Github API token."
  type        = string
  sensitive   = true
}

variable "repository_name" {
  description = "The Github repository name."
  type        = string
}