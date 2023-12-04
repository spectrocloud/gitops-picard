variable "cluster_name" {
  description = "Name of the cluster (e.g: px-npe2300)"
}
variable "cluster_workers_per_az" {
  type        = number
  description = "Number of workers per zone (e.g: 3)"
}

variable "maas_api_endpoint" {
  description = "The MaaS endpoint that Palette will connect to"
  default     = ""
}

variable "maas_api_key" {
  description = "The MaaS API key to use for authentication"
  default     = ""
}

# Cluster
variable "private_cloud_gateway_id" {
  description = "The private cloud gateway or the system gateway (for on-prem cases) id to connect to for provisioning the clusters"
  default     = ""
}

variable "maas_resource_pool" {
  description = "The MaaS resource pool to use for cluster management"
  default     = ""
}

variable "maas_domain" {
  description = "The MaaS domain that Palette should connect to"
  default     = ""
}

variable "maas_azs" {
  description = "The MaaS AZs to use in the node pools"
  default     = ""
}

variable "machine_pool_labels" {
  description = "These lables will be additional labels for machine pool in cluster."
  default     = {}
}

variable "cluster_profile_id" {
  description = "The ID of the Cluster Profile"
}

variable "netscaler_vip_api" {
  description = "The Virtual Service VIP for API/CP"
  default     = ""
}

variable "netscaler_vip_nodeport" {
  description = "The Virtual Service VIP for NODEPORT"
  default     = ""
}

variable "netscaler_vip_ingress" {
  description = "The Virtual Service VIP for INGRESS"
  default     = ""
}

variable "cluster_packs" {
  type = map(object({
    tag  = string
    file = string
  }))
}

# Relatively stable config
variable "global_config" {
  type = object({
    dns_domain       = string
    pcg_id           = string
    cloud_account_id = string

    vault_secrets_admin_conf_path  = string
    vault_secrets_admin2_conf_path = string
    vault_secrets_etcd_key_path    = string
    vault_secrets_etcd_certs_path  = string
    vault_ssh_keys_path            = string
  })
}

locals {
  n               = var.cluster_name
  fqdn            = "${var.cluster_name}.${var.global_config.dns_domain}"
}
