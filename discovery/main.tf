terraform {
  required_version = ">= 0.13"
  # backend "etcdv3" {
  #   lock        = true
  #   prefix      = "/s2/"
  #   endpoints   = ["35.203.171.218:2379"]
  #   cacert_path = "certs/ca.crt"
  #   cert_path   = "certs/client.crt"
  #   key_path    = "certs/client.key"
  # }

  required_providers {
    vault = {
      version = "~> 2.18.0"
      source  = "hashicorp/vault"
    }

    spectrocloud = {
      version = "~> 0.2.1"
      source  = "spectrocloud/spectrocloud"
    }

    citrixadc = {
      source  = "citrix.com/test/citrixadc"
      version = "~> 0.12.44"
    }
  }
}


variable "vault_approle_role_id" {}
variable "vault_approle_secret_id" {}

provider "vault" {
  address = local.global_vault_addr
  max_lease_ttl_seconds = 3 * 60 * 60
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.vault_approle_role_id
      secret_id = var.vault_approle_secret_id
    }
  }
}

data "vault_generic_secret" "sc_mgmt" {
  path = "pe/ci/tke/px-npe2/tke-px-npe2002/mgmt-cluster"
}

provider "spectrocloud" {
  username = data.vault_generic_secret.sc_mgmt.data.username
  password = data.vault_generic_secret.sc_mgmt.data.password
  host = data.vault_generic_secret.sc_mgmt.data.host

  project_name              = "Default"
  ignore_insecure_tls_error = true
}

data "vault_generic_secret" "netscaler" {
  path = "pe/ci/tke/px-npe2/shared/netscaler"
}
provider "citrixadc" {
  # T-Mo might need to remove the `.data` (?)
  username = data.vault_generic_secret.netscaler.data.username
  password = data.vault_generic_secret.netscaler.data.password
  endpoint = data.vault_generic_secret.netscaler.data.endpoint
}
