terraform {
  backend "s3" {
    bucket = "terraform-state-spectro"
    key    = "project-edison-ai/terraform.tfstate"
    region = "us-east-1"
    #endpoint                    = "https://10.10.137.64:9000"
    #skip_credentials_validation = true
    #skip_metadata_api_check     = true
    #skip_region_validation      = true
    #force_path_style            = true
    #access_key, secret_key initialize with backend-config
  }
}

data "spectrocloud_cloudaccount_aws" "default" {
  name = "aws-eks"
}

data "spectrocloud_cluster_profile" "sc" {
  name    = "ProdEKS-minimum"
  version = "1.0.1"
}

