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
    key    = "project-maas-clusters/terraform.tfstate"
    region = "us-east-1"
    #endpoint                    = "https://10.10.137.64:9000"
    #skip_credentials_validation = true
    #skip_metadata_api_check     = true
    #skip_region_validation      = true
    #force_path_style            = true
    #access_key, secret_key initialize with backend-config
  }
}
locals {
  # TODO remove?
  datacenter             = "Datacenter"
  cluster_ssh_public_key = <<-EOT
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCr3hE9IS5UUDPqNOiEWVJvVDS0v57QKjb1o9ubvvATQNg2T3x+inckfzfgX3et1H9X1oSp0FqY1+Mmy5nfTtTyIj5Get1cntcC4QqdZV8Op1tmpI01hYMj4lLn55WNaXgDt+35tJ47kWRr5RqTGV05MPNWN3klaVsePsqa+MgCjnLfCBiOz1tpBOgxqPNqtQPXh+/T/Ul6ZDUW/rySr9iNR9uGd04tYzD7wdTdvmZSRgWEre//IipNzMnnZC7El5KJCQn8ksF+DYY9eT9NtNFEMALTZC6hn8BnMc14zqxoJP/GNHftmig8TJC500Uofdr4OKTCRr1JwHS79Cx9LyZdAp/1D8mL6bIMyGOTPVQ8xUpmEYj77m1kdiCHCk22YtLyfUWuQ0SC+2p1soDoNfJUpmxcKboOTZsLq1HDCFrqSyLUWS1PrYZ/MzhsPrsDewB1iHLbYDt87r2odJOpxMO1vNWMOYontODdr5JPKBpCcd/noNyOy/m4Spntytfb/J3kM1oz3dpPfN0xXmC19uR1xHklmbtg1j784IMu7umI2ZCpUwLADAodkbxmbacdkp5I+1NFgrFamvnTjjQAvRexV31m4m9GielKFQ4tCCId2yagMBWRFn5taEhb3SKnRxBcAzaJLopUyErOtqxvSywGvb53v4MEShqBaQSUv4gHfw== spectro2022
  EOT
}

variable "sc_host" {}
variable "sc_api_key" {}
variable "sc_project_name" {}

provider "spectrocloud" {
  host         = var.sc_host
  api_key      = var.sc_api_key
  project_name = var.sc_project_name
}
