terraform {
  backend "s3" {
    bucket                      = "terraform-state"
    key                         = "photon/terraform.tfstate"
    region                      = "ignored"
    endpoint                    = "https://10.10.137.64:9000"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
    #access_key, secret_key initialize with backend-config
  }
}

# locals
locals {

  global_config = {
    # Domain
    dns_domain       = "discovery.spectrocloud.com"
    cloud_account_id = data.spectrocloud_cloudaccount_aws.default.id

    # Vault
    # vault_secrets_path            = "sc/env1/admin_creds"
    # vault_secrets_etcd_certs_path = "sc/env1/etcd-certs"

    # VM properties
    # datacenter     = "Datacenter"
    # vm_folder      = "Demo"
    # ssh_public_key = <<-EOT
    #   ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAUaBODDNpQxJJqXz/Q+afauM5EPFp4oDRrWzK/cGd92N+exkd+tEZdO7n3R+WAx0XTcPiVvfKctzekNS6f/ZMrFb5HAPvFJtnGNIE2sm+eryEnAH+Sc7ppZha3/MaSp/A2dm2IobYRvwl04sEi4w1K+I8Rtt+fBe3gV3wnP3E3yOiRx4G2XFC3T6x8MjdOkjO2v6fBluw1M1H2etp1m/n4D70UkeyVJyipcntz0ubHweU7yPNdNS3YkpExYIGhm97C4dyESHEw9PZVdLs1FBL6mW5Yb4qVbg5FkLljLFynh9jL8IAYal0pibAAH+Sk/Nd4865lVJ3lrm8nhBnjs1OEFA487rcxyInxJk/WwLEHvo88Ku9IlYq15Alr8N/JHHackV4kAH0yJNeLtwAysK2gI7Mb5uGnMTPrz73IZqXSxFqnU34Ow+vwu8fXBtXmHA5cUHyz0ARzpgx8A0e8L8SjdY/6dsFhSzGo7JoCElN7sEMo7iI4Wdo8CYdlT+OXizBf3pnM/wxRZclCeRDJpLtd6jl5swv7J5ocINEh1r3BllCyV8L7Xp5gw8IKT3ohz6rliGJwwlq/emqY52eB3wweTLRm30z3h3aQa3YeAR+2JgvWlrJ3YWsYYCLRhSQTfYmpgUkoZIcfB2xkZzp6cyooM0i5Obz313HsxwBHOmNrw== spectro@spectro
    # EOT

    # worker_node = {
    #   cpu       = 4
    #   memory_mb = 8192
    #   disk_gb   = 60
    # }

    # Datastore supports a %DS% template macro
    # which is replaced with var.cluster_datastore
    # placements = [
    #   {
    #     cluster       = "cluster1"
    #     resource_pool = ""
    #     datastore     = "datastore54"
    #   },
    #   {
    #     cluster       = "cluster2"
    #     resource_pool = ""
    #     datastore     = "datastore55"
    #   },
    #   {
    #     cluster       = "cluster3"
    #     resource_pool = ""
    #     datastore     = "datastore56"
    #   }
    # ]
  }
}

data "spectrocloud_cloudaccount_aws" "default" {
  name = "aws-picard-2"
}
