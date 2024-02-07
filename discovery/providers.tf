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

    tls = {
      source = "hashicorp/tls"
      version = "3.4.0"
    }
  }
}

# Vault
provider "vault" {
  address               = var.vault_address
  token_name            = "sc_child"
  max_lease_ttl_seconds = 3 * 60 * 60
  skip_tls_verify = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.vault_approle_role_id
      secret_id = var.vault_approle_secret_id
    }
  }
}

# Spectro Cloud
provider "spectrocloud" {
  host         = var.sc_host
  username     = var.sc_username
  password     = var.sc_password
  project_name = var.sc_project_name
  ignore_insecure_tls_error = true
}

# Citrix ADC/Netscaler
provider "citrixadc" {
  username = var.ns_user
  password = var.ns_password
  endpoint = var.ns_endpoint
}