terraform {
  required_version = ">= 0.14.0"

  required_providers {
    spectrocloud = {
      #version = "> 0.4.1"
      source = "spectrocloud/spectrocloud"
    }
  }

  backend "s3" {
    bucket = "terraform-state-spectro"
    key    = "project-edison-ai-yaml/terraform.tfstate"
    region = "us-east-1"
    #endpoint                    = "https://10.10.137.64:9000"
    #skip_credentials_validation = true
    #skip_metadata_api_check     = true
    #skip_region_validation      = true
    #force_path_style            = true
    #access_key, secret_key initialize with backend-config
  }
}

# Spectro Cloud
variable "sc_host" {}
variable "sc_api_key" {}
variable "sc_project_name" {}

provider "spectrocloud" {
  host         = var.sc_host
  api_key      = var.sc_api_key
  project_name = var.sc_project_name
}

data "spectrocloud_cloudaccount_aws" "default" {
  name = "aws-stage-picard"
}

data "spectrocloud_cluster_profile" "sc" {
  name    = "ProdEKS"
  version = "1.0.0"
}

