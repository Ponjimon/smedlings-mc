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
    github = {
      source  = "integrations/github"
      version = "5.31.0"
    }
    random = {
      source = "hashicorp/random"
    }
    template = {
      source = "hashicorp/template"
    }
  }

  backend "s3" {
    bucket     = var.r2_bucket
    key        = "terraform.tfstate"
    region     = "auto"
    endpoint   = var.r2_endpoint
    access_key = var.r2_access_key
    secret_key = var.r2_secret_key

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_meta_api_check         = true
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "github" {
  token = var.github_token
}

provider "random" {
}