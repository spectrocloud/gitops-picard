terraform {
  required_version = ">= 0.12.0"
  backend "etcdv3" {
    lock   = true
    prefix = "/spectrocloud/"
  }

  required_providers {
    spectrocloud = {
      version = ">= 0.1"
      source  = "spectrocloud/spectrocloud"
    }
  }
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
