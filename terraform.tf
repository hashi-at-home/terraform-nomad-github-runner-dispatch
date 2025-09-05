terraform {
  required_version = "~> 1.13"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 1.0"
    }
    # If your tokens are in vault
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.0"
    }
  }

  backend "consul" {
    path = "terraform/hashi-at-home/platform/delivery-plane/github-runners"
  }
}

data "vault_kv_secret_v2" "cloudflare" {
  mount = "cloudflare"
  name  = "brucellino.dev"
}

data "vault_nomad_access_token" "nomad" {
  backend = "nomad"
  role    = "mgmt"

}

provider "cloudflare" {
  api_token = data.vault_kv_secret_v2.cloudflare.data["token"]
}

provider "nomad" {
  address   = "http://nomad.service.consul:4646"
  secret_id = data.vault_nomad_access_token.nomad.secret_id
}
