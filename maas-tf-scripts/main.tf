terraform {
  required_version = ">= 0.15.0"
  backend "etcdv3" {
    lock   = true
    prefix = "/spectrocloud-maas/"
    #endpoints  = ["ip:2379"] # Passed in from terraform
    cacert_path = "certs/ca.crt"
    cert_path   = "certs/client.crt"
    key_path    = "certs/client.key"
  }


  required_providers {
    spectrocloud = {
      version = "=0.10.5"
      source  = "spectrocloud/spectrocloud"
    }
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
