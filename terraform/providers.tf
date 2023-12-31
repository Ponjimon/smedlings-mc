terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.10.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.41.0"
    }
    random = {
      source = "hashicorp/random"
    }
    template = {
      source = "hashicorp/template"
    }
  }

  backend "s3" {}
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "random" {
}