locals {

  oidc_args = {
    oidc-issuer-url : "https://%ISSUER_URL%"
    oidc-client-id : "spectrocloud"
    oidc-username-claim : "email"
    oidc-username-prefix : "-"
    oidc-groups-claim : "groups"
  }

  oidc_args_string = join("\n", [for k, v in local.oidc_args : format("%s: \"%s\"", k, v)])

  # Network
  global_pcg_id                       = "603e528439ea6effbcd224d8"
  global_network_prefix               = 18
  global_network_gateway              = "10.10.192.1"
  global_network_nameserver_addresses = ["10.10.128.8", "8.8.8.8"]
  global_vault_addr                   = "http://vault.app.picard.spectrocloud.com:8200"

  global_dhcp_search = "spectrocloud.local"

  # VM properties
  global_datacenter     = "Datacenter"
  global_vm_folder      = "Demo"
  global_ssh_public_key = <<-EOT
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAUaBODDNpQxJJqXz/Q+afauM5EPFp4oDRrWzK/cGd92N+exkd+tEZdO7n3R+WAx0XTcPiVvfKctzekNS6f/ZMrFb5HAPvFJtnGNIE2sm+eryEnAH+Sc7ppZha3/MaSp/A2dm2IobYRvwl04sEi4w1K+I8Rtt+fBe3gV3wnP3E3yOiRx4G2XFC3T6x8MjdOkjO2v6fBluw1M1H2etp1m/n4D70UkeyVJyipcntz0ubHweU7yPNdNS3YkpExYIGhm97C4dyESHEw9PZVdLs1FBL6mW5Yb4qVbg5FkLljLFynh9jL8IAYal0pibAAH+Sk/Nd4865lVJ3lrm8nhBnjs1OEFA487rcxyInxJk/WwLEHvo88Ku9IlYq15Alr8N/JHHackV4kAH0yJNeLtwAysK2gI7Mb5uGnMTPrz73IZqXSxFqnU34Ow+vwu8fXBtXmHA5cUHyz0ARzpgx8A0e8L8SjdY/6dsFhSzGo7JoCElN7sEMo7iI4Wdo8CYdlT+OXizBf3pnM/wxRZclCeRDJpLtd6jl5swv7J5ocINEh1r3BllCyV8L7Xp5gw8IKT3ohz6rliGJwwlq/emqY52eB3wweTLRm30z3h3aQa3YeAR+2JgvWlrJ3YWsYYCLRhSQTfYmpgUkoZIcfB2xkZzp6cyooM0i5Obz313HsxwBHOmNrw== spectro@spectro
  EOT
}

locals {


}

data "spectrocloud_cloudaccount_vsphere" "this" {
  name = "vcenter2"
}

data "spectrocloud_pack" "vault" {
  name    = "vault"
  version = "0.9.0"
}

data "spectrocloud_pack" "dex" {
  name    = "dex"
  version = "2.28.0"
}

data "spectrocloud_pack" "byom" {
  name    = "spectro-byo-manifest"
  version = "1.0.0"
}

data "spectrocloud_pack" "prometheus-vsphere" {
  name    = "prometheus-operator"
  version = "9.7.2"
}

data "spectrocloud_pack" "nginx-vsphere" {
  name    = "nginx"
  version = "0.43.0"
}

data "spectrocloud_pack" "hipster-vsphere" {
  name    = "sapp-hipster"
  version = "2.0.0"
}

data "spectrocloud_pack" "lbmetal-vsphere" {
  name    = "lb-metallb"
  version = "0.9.5"
}

data "spectrocloud_pack" "istio-vsphere" {
  name    = "istio"
  version = "1.6.2"
}

data "spectrocloud_pack" "csi-vsphere" {
  name = "csi-vsphere-volume"
  # version  = "1.0.x"
}

data "spectrocloud_pack" "cni-vsphere" {
  name    = "cni-calico"
  version = "3.16.0"
}

data "spectrocloud_pack" "k8s-vsphere" {
  name    = "kubernetes"
  version = "1.18.15"
}

data "spectrocloud_pack" "ubuntu-vsphere" {
  name = "ubuntu-vsphere"
  # version  = "1.0.x"
}

