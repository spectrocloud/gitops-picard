
terraform {
  required_version = ">= 1.3.1"

  cloud {
    organization = "spectrocloud-demo"

    workspaces {
      name = "gitops-picard-phoenix"
    }
  }

  required_providers {
    spectrocloud = {
      version = ">= 0.11.0"
      source  = "spectrocloud/spectrocloud"
    }
  }
}

provider "spectrocloud" {
  host         = var.sc_host
  api_key      = var.sc_api_key
  project_name = var.sc_project_name
  trace = true
}
