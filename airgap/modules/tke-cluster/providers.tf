terraform {
  required_providers {
    vault = {
      version = "~> 2.18.0"
      source  = "hashicorp/vault"
    }

    spectrocloud = {
      version = "~> 0.5.4"
      source  = "spectrocloud/spectrocloud"
    }

    citrixadc = {
      source  = "citrix.com/test/citrixadc"
      version = "~> 0.12.44"
    }
  }
}
