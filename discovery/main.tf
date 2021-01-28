terraform {
  required_version = ">= 0.12.0"
  # backend "etcdv3" {
  #   lock        = true
  #   prefix      = "/s2/"
  #   endpoints   = ["35.203.171.218:2379"]
  #   cacert_path = "certs/ca.crt"
  #   cert_path   = "certs/client.crt"
  #   key_path    = "certs/client.key"
  # }

  required_providers {
    spectrocloud = {
      version = ">= 0.1.20"
      source  = "spectrocloud/spectrocloud"
    }
  }
}

variable "sc_host" {}
variable "sc_username" {}
variable "sc_password" {}
variable "sc_project_name" {}

provider "spectrocloud" {
  host                      = var.sc_host
  username                  = var.sc_username
  password                  = var.sc_password
  project_name              = var.sc_project_name
  ignore_insecure_tls_error = true
}
