terraform {
  required_version = ">= 0.14.0"
  required_providers {
    vault = {
      version = "~> 2.18.0"
      source  = "hashicorp/vault"
    }

    spectrocloud = {
      version = "0.14.2"
      source  = "spectrocloud/spectrocloud"
    }

    citrixadc = {
      source  = "citrix.com/test/citrixadc"
      version = "~> 0.12.44"
    }
  }
}

provider "vault" {
  address               = var.vault_address
  max_lease_ttl_seconds = 3 * 60 * 60
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.vault_approle_role_id
      secret_id = var.vault_approle_secret_id
    }
  }
}

provider "spectrocloud" {
  host         = var.sc_host
  username     = var.sc_username
  password     = var.sc_password
  project_name = var.sc_project_name
  #trace        = true
}

provider "citrixadc" {
  username = var.ns_user
  password = var.ns_password
  endpoint = var.ns_endpoint
}
