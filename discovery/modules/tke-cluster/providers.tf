terraform {
  required_providers {
    vault = {
      version = "~> 2.18.0"
      source  = "hashicorp/vault"
    }

    spectrocloud = {
      version = "~> 0.3.2"
      source  = "spectrocloud/spectrocloud"
    }

    citrixadc = {
      source  = "citrix.com/test/citrixadc"
      version = "~> 0.12.44"
    }
  }
}
