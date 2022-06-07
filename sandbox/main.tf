terraform {
  required_version = ">= 0.12.0"
  backend "etcdv3" {
    lock   = true
    prefix = "/spectrocloud/"
    #endpoints  = ["ip:2379"] # Passed in from terraform
    cacert_path = "certs/ca.crt"
    cert_path   = "certs/client.crt"
    key_path    = "certs/client.key"
  }


  required_providers {
    spectrocloud = {
      version = "~> 0.5.0"
      source  = "spectrocloud/spectrocloud"
    }
  }
}

locals {
  oidc_args = {
    oidc-issuer-url : "https://dev-6428100.okta.com/oauth2/default"
    oidc-client-id : "0oa4fe1y3zjc2W2nc5d6"
    oidc-username-claim : "email"
    oidc-username-prefix : "-"
    oidc-groups-claim : "groups"
  }

  oidc_args_string = join("\n", [for k, v in local.oidc_args : format("%s: \"%s\"", k, v)])
}

locals {
  datacenter = "Datacenter"
  folder     = "Demo"

  cluster_network_search = "spectrocloud.dev"

  cluster_ssh_public_key = <<-EOT
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAUaBODDNpQxJJqXz/Q+afauM5EPFp4oDRrWzK/cGd92N+exkd+tEZdO7n3R+WAx0XTcPiVvfKctzekNS6f/ZMrFb5HAPvFJtnGNIE2sm+eryEnAH+Sc7ppZha3/MaSp/A2dm2IobYRvwl04sEi4w1K+I8Rtt+fBe3gV3wnP3E3yOiRx4G2XFC3T6x8MjdOkjO2v6fBluw1M1H2etp1m/n4D70UkeyVJyipcntz0ubHweU7yPNdNS3YkpExYIGhm97C4dyESHEw9PZVdLs1FBL6mW5Yb4qVbg5FkLljLFynh9jL8IAYal0pibAAH+Sk/Nd4865lVJ3lrm8nhBnjs1OEFA487rcxyInxJk/WwLEHvo88Ku9IlYq15Alr8N/JHHackV4kAH0yJNeLtwAysK2gI7Mb5uGnMTPrz73IZqXSxFqnU34Ow+vwu8fXBtXmHA5cUHyz0ARzpgx8A0e8L8SjdY/6dsFhSzGo7JoCElN7sEMo7iI4Wdo8CYdlT+OXizBf3pnM/wxRZclCeRDJpLtd6jl5swv7J5ocINEh1r3BllCyV8L7Xp5gw8IKT3ohz6rliGJwwlq/emqY52eB3wweTLRm30z3h3aQa3YeAR+2JgvWlrJ3YWsYYCLRhSQTfYmpgUkoZIcfB2xkZzp6cyooM0i5Obz313HsxwBHOmNrw== spectro@spectro
  EOT
}

variable "sc_host" {}
variable "sc_username" {}
variable "sc_password" {}
variable "sc_project_name" {}

provider "spectrocloud" {
  host         = var.sc_host
  username     = var.sc_username
  password     = var.sc_password
  project_name = var.sc_project_name
}
