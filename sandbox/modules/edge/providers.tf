terraform {
  required_providers {
    spectrocloud = {
      version = ">= 0.7.0"
      source  = "spectrocloud/spectrocloud"
    }
  }
  experiments = [module_variable_optional_attrs]
}