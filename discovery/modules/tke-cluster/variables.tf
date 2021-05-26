variable "cluster_name" {
  description = "Name of the cluster (e.g: sc-npe1701)"
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

    vault_secrets_path = string
    vault_secrets_etcd_certs_path = string
    vault_ssh_keys_path = string

    # Network
    network_prefix  = string
    network_nameserver_addresses = list(string)
    networks = map(object({gateway = string, network = string}))

    # VM properties
    datacenter  = string
    vm_folder  = string
    ssh_public_key  = string

    worker_node = object({
      cpu = number
      memory_mb = number
      disk_gb = number
    })

    api_node = object({
      cpu = number
      memory_mb = number
      disk_gb = number
    })

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
