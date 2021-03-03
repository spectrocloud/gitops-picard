terraform {
  required_version = ">= 0.12.0"
  backend "etcdv3" {
    lock   = true
    prefix = "/spectrocloud/"
    #endpoints  = ["ip:2379"] # Passed in from terraform
    cacert_path = "certs/ca.crt"
    cert_path   = "certs/client.crt"
    key_path    = "certs/client.key"
  }

  required_providers {
    spectrocloud = {
      version = "~> 0.2.0"
      source  = "spectrocloud/spectrocloud"
    }
  }
}

locals {
  oidc_args = {
    oidc-issuer-url : "https://dev-6428100.okta.com/oauth2/default"
    oidc-client-id : "0oa4fe1y3zjc2W2nc5d6"
    oidc-username-claim : "email"
    oidc-username-prefix : "-"
    oidc-groups-claim : "groups"
  }

  oidc_args_string = join("\n", [for k, v in local.oidc_args : format("%s: \"%s\"", k, v)])
}

variable "sc_host" {}
variable "sc_username" {}
variable "sc_password" {}
variable "sc_project_name" {}

provider "spectrocloud" {
  host         = var.sc_host
  username     = var.sc_username
  password     = var.sc_password
  project_name = var.sc_project_name
}

