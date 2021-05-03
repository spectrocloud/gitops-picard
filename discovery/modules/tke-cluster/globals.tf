# SAM

# locals {
#   # Domain
#   global_dns_domain                   = "tke.t-mobile.com"
#   # Network
#   global_pcg_id                       = "6089b3f908a4a86f69786b68"
#   global_network_prefix               = 24
#   global_network_nameserver_addresses = ["10.66.3.25", "10.66.3.26"]
#   # VM properties
#   global_datacenter     = "Polaris_CaaS_NPE02"
#   global_vm_folder      = "px-npe2003_vms"
#   global_ssh_public_key = <<-EOT
#     ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDdgN6j00rAK2KJ0QfY9tJH+gkP4OXLmaV4ArwV/iHO3FKh1ykZa3TiFznUTkuHePtrJmXCT62V4gJ+2qJ5E2RtaYXMcoztwlil5iPRVxplo6VQEHNH/d1B78116MDx3VCotUP5HsmPJH5+zNp0KivZqa2vGEpOkElSjHeg9jRc3SozRoX0lc/jspU1PXRmGnNOtnOW0l/uKUF7STyN5nVWEvQeN1Cx5nPjANngyjdXKc2X491/TvSERmjQvEWnfIDCpHpNlmazG6xnG4SwIk0jhu6ahvz5okKJKGL513y/1u/6Y622yW35yHHeaX9hUv1NRcVsr6Gfo5d5ZXHSDPd1
#   EOT
# }

# SAM-delete
# locals {

#   # Domain
#   global_dns_domain                   = "discovery.spectrocloud.com"
#   # Network
#   global_pcg_id                       = "603e528439ea6effbcd224d8"
#   global_network_prefix               = 18
#   global_network_nameserver_addresses = ["10.10.128.8", "8.8.8.8"]
#   global_networks = {
#     "10.10.242" = {
#       gateway = "10.10.192.1"
#       network = "VM Network 2"
#     }
#   }
#   global_current_network = local.global_networks[var.cluster_network]

#   # VM properties
#   global_datacenter     = "Datacenter"
#   global_vm_folder      = "Demo"
#   global_ssh_public_key = <<-EOT
#     ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAUaBODDNpQxJJqXz/Q+afauM5EPFp4oDRrWzK/cGd92N+exkd+tEZdO7n3R+WAx0XTcPiVvfKctzekNS6f/ZMrFb5HAPvFJtnGNIE2sm+eryEnAH+Sc7ppZha3/MaSp/A2dm2IobYRvwl04sEi4w1K+I8Rtt+fBe3gV3wnP3E3yOiRx4G2XFC3T6x8MjdOkjO2v6fBluw1M1H2etp1m/n4D70UkeyVJyipcntz0ubHweU7yPNdNS3YkpExYIGhm97C4dyESHEw9PZVdLs1FBL6mW5Yb4qVbg5FkLljLFynh9jL8IAYal0pibAAH+Sk/Nd4865lVJ3lrm8nhBnjs1OEFA487rcxyInxJk/WwLEHvo88Ku9IlYq15Alr8N/JHHackV4kAH0yJNeLtwAysK2gI7Mb5uGnMTPrz73IZqXSxFqnU34Ow+vwu8fXBtXmHA5cUHyz0ARzpgx8A0e8L8SjdY/6dsFhSzGo7JoCElN7sEMo7iI4Wdo8CYdlT+OXizBf3pnM/wxRZclCeRDJpLtd6jl5swv7J5ocINEh1r3BllCyV8L7Xp5gw8IKT3ohz6rliGJwwlq/emqY52eB3wweTLRm30z3h3aQa3YeAR+2JgvWlrJ3YWsYYCLRhSQTfYmpgUkoZIcfB2xkZzp6cyooM0i5Obz313HsxwBHOmNrw== spectro@spectro
#   EOT

#   global_placements = [
#     {
#       cluster           = "cluster1"
#       resource_pool     = ""
#       datastore         = "datastore54"
#       network           = local.global_current_network.network
#     },
#     {
#       cluster           = "cluster2"
#       resource_pool     = ""
#       datastore         = "datastore55"
#       network           = local.global_current_network.network
#     },
#     {
#       cluster           = "cluster3"
#       resource_pool     = ""
#       datastore         = "datastore56"
#       network           = local.global_current_network.network
#     }
#   ]
# }

# data "spectrocloud_cloudaccount_vsphere" "default" {
#   name = "npe2003"
# }

    # placement {
    #   cluster           = "PXNPECAAS32704az1a"
    #   resource_pool     = "82-NPE-PX2003-AZ1"
    #   datastore         = "TKE_PXNPECAAS32704AZ1A_THK_T0_PXCFPUR0904_PXNPE3_${var.cluster_datastore}"
    #   network           = "PXCAASNPE02A_TKE_NPE2003_01_10.142.149.0_24_v737"
    #   static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.api.id
    # }
    # placement {
    #   cluster           = "PXNPECAAS32705az2a"
    #   resource_pool     = "82-NPE-PX2003-AZ2"
    #   datastore         = "TKE_PXNPECAAS32705AZ2A_THK_T0_PXCFPUR0905_PXNPE3_${var.cluster_datastore}"
    #   network           = "PXCAASNPE02A_TKE_NPE2003_01_10.142.149.0_24_v737"
    #   static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.api.id
    # }
    # placement {
    #   cluster           = "PXNPECAAS32706az3a"
    #   resource_pool     = "82-NPE-PX2003-AZ3"
    #   datastore         = "TKE_PXNPECAAS32706AZ3A_THK_T0_PXCFPUR0906_PXNPE3_${var.cluster_datastore}"
    #   network           = "PXCAASNPE02A_TKE_NPE2003_01_10.142.149.0_24_v737"
    #   static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.api.id
    # }
