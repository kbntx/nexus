terraform {
  required_version = "1.15.9"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.52"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 5"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://2bde0126da63a3a9c94029d14ea380db.eu.r2.cloudflarestorage.com"
    }
    bucket                      = "nexus-terraform-state"
    key                         = "kubernetes/state/terraform.tfstate"
    region                      = "eeur"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}

