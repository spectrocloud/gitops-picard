variable "node_pools" {
  description = "Values for the attributes of the Node Pools.  'edge_host_tags' is used to lookup the Edge Host already registered with Palette."
  type = list(object({
    name           = string
    pool_labels    = optional(map(string))
    control_plane  = bool
    edge_host_tags = optional(map(string))
    edge_host_uid  = optional(list(string))
  }))
}
variable "cluster_tags" {
  type        = list(string)
  description = "Tags to be added to the profile.  key:value"
  default     = []
}
variable "name" {
  type        = string
  description = "Name of the cluster to be created."
}
variable "cluster_profiles" {
  description = "Values for the profile(s) to be used for cluster creation.  For `context` a value of [project tenant system] is expected."
  type = list(object({
    name    = string
    tag     = optional(string)
    context = string # project tenant system
    packs = optional(list(object({
      name   = string
      tag    = string
      values = optional(string)
      manifest = optional(list(object({
        name    = string
        tag     = string
        content = string
      })))
    })))
  }))
}

variable "rbac_bindings" {
  description = "RBAC Bindings to be added to the cluster"
  type = list(object({
    rbac_type = string
    namespace = optional(string)
    rbac_role = optional(map(string))
    subjects = optional(list(object({
      name      = string
      rbac_type = string
      namespace = optional(string)
    })))
  }))
  default = []
}
variable "cluster_vip" {
  type        = string
  description = "IP Address for Cluster VIP for HA.  Must be unused on on the same layer 2 segment as the node IPs."
}
variable "ssh_keys" {
  type    = string
  default = ""
}
variable "ntp_servers" {
  type    = list(string)
  default = []
}
variable "skip_wait_for_completion" {
  type    = bool
  default = true
}
variable "location" {
  type = object({
    latitude  = optional(number)
    longitude = optional(number)
  })
  default = {
    latitude  = 0
    longitude = 0
  }
  description = "Optional - If used Latitude and Longitude represent the coordinates of the location you wish to assign to the cluster.  https://www.latlong.net/ is one tool that can be used to find this."
}

variable "binding_type" {
  type        = string
  description = "Role binding type to be created with the cluster."
  default     = null
}

variable "binding_role" {
  type        = map(string)
  description = "Role binding type to be created with the cluster."
  default     = null
}
