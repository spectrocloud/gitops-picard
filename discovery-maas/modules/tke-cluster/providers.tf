terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
    }
    tls = {
      source  = "hashicorp/tls"
    }
    spectrocloud = {
      source = "spectrocloud/spectrocloud"
    }
    citrixadc = {
      source  = "citrix.com/test/citrixadc"
    }
  }
}
