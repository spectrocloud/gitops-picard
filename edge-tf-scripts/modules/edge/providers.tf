terraform {
  required_providers {
    spectrocloud = {
      version = ">= 0.10.5"
      source  = "spectrocloud/spectrocloud"
    }
  }
  experiments = [module_variable_optional_attrs]
  required_version = ">= 1.2.8"
}