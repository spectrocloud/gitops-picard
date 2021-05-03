variable "cluster_name" {
  description = "Name of the cluster (e.g: px-npe2300)"
}
variable "cluster_workers_per_az" {
  type = number
  description = "Number of workers per zone (e.g: 3)"
}
variable "cluster_datastore" {
  description = "Datastore (e.g: DS001)"
  default = ""
}
variable "cluster_network" {
  description = "The network first three octets (e.g: 10.142.149)"
}
variable "cluster_api_start_ip" {
  description = "Start IP of the Kube API Server (e.g: 10)"
}
variable "cluster_api_end_ip" {
  description = "End IP of the Kube API Server (e.g: 15)"
}

variable "cluster_worker_start_ip" {
  description = "Start IP of the Kube API Server (e.g: 10)"
}
variable "cluster_worker_end_ip" {
  description = "End IP of the Kube API Server (e.g: 15)"
}

variable "cluster_profile_id" {
  description = "The ID of the Cluster Profile"
}

variable "netscaler_vip_api" {
  description = "The Virtual Service VIP for API/CP"
}
variable "netscaler_vip_nodeport" {
  description = "The Virtual Service VIP for NODEPORT"
}
variable "netscaler_vip_ingress" {
  description = "The Virtual Service VIP for INGRESS"
}

variable "cluster_packs" {
  type = map(object({
    tag = string
    file = string
  }))
}

# Relatively stable config
variable "global_config" {
  type = object({
    dns_domain = string
    pcg_id = string
    cloud_account_id = string

    # Network
    network_prefix  = string
    network_nameserver_addresses = list(string)
    networks = map(object({gateway = string, network = string}))

    # VM properties
    datacenter  = string
    vm_folder  = string
    ssh_public_key  = string

    placements = list(object({
      cluster = string
      resource_pool = string
      datastore = string
    }))
  })
}

locals {
  n = var.cluster_name
  current_network = var.global_config.networks[var.cluster_network]
  fqdn     = "${var.cluster_name}.${var.global_config.dns_domain}"

  placements = [for i, v in var.global_config.placements : {
    cluster           = v.cluster
    resource_pool     = v.resource_pool
    datastore         = replace(v.datastore, "%DS%", var.cluster_datastore)
    network           = local.current_network.network
  }]
}

# # Network
# variable "pcg_id                       = "603e528439ea6effbcd224d8"
# variable "network_prefix               = 18
# variable "network_nameserver_addresses = ["10.10.128.8", "8.8.8.8"]
# variable "networks = {
#   "10.10.242" = {
#     gateway = "10.10.192.1"
#     network = "VM Network 2"
#   }
# }
# variable "current_network = local.global_networks[var.cluster_network]

# # VM properties
# variable "datacenter     = "Datacenter"
# variable "vm_folder      = "Demo"
# variable "ssh_public_key = <<-EOT
#   ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAUaBODDNpQxJJqXz/Q+afauM5EPFp4oDRrWzK/cGd92N+exkd+tEZdO7n3R+WAx0XTcPiVvfKctzekNS6f/ZMrFb5HAPvFJtnGNIE2sm+eryEnAH+Sc7ppZha3/MaSp/A2dm2IobYRvwl04sEi4w1K+I8Rtt+fBe3gV3wnP3E3yOiRx4G2XFC3T6x8MjdOkjO2v6fBluw1M1H2etp1m/n4D70UkeyVJyipcntz0ubHweU7yPNdNS3YkpExYIGhm97C4dyESHEw9PZVdLs1FBL6mW5Yb4qVbg5FkLljLFynh9jL8IAYal0pibAAH+Sk/Nd4865lVJ3lrm8nhBnjs1OEFA487rcxyInxJk/WwLEHvo88Ku9IlYq15Alr8N/JHHackV4kAH0yJNeLtwAysK2gI7Mb5uGnMTPrz73IZqXSxFqnU34Ow+vwu8fXBtXmHA5cUHyz0ARzpgx8A0e8L8SjdY/6dsFhSzGo7JoCElN7sEMo7iI4Wdo8CYdlT+OXizBf3pnM/wxRZclCeRDJpLtd6jl5swv7J5ocINEh1r3BllCyV8L7Xp5gw8IKT3ohz6rliGJwwlq/emqY52eB3wweTLRm30z3h3aQa3YeAR+2JgvWlrJ3YWsYYCLRhSQTfYmpgUkoZIcfB2xkZzp6cyooM0i5Obz313HsxwBHOmNrw== spectro@spectro
# EOT

# variable "placements = [
#   {
#     cluster           = "cluster1"
#     resource_pool     = ""
#     datastore         = "datastore54"
#     network           = local.variable "current_network.network
#   },
#   {
#     cluster           = "cluster2"
#     resource_pool     = ""
#     datastore         = "datastore55"
#     network           = local.variable "current_network.network
#   },
#   {
#     cluster           = "cluster3"
#     resource_pool     = ""
#     datastore         = "datastore56"
#     network           = local.variable "current_network.network
#   }
# ]
# }


