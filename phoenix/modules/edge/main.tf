data "spectrocloud_cluster_profile" "this" {
  for_each = {
    for profile in var.cluster_profiles : profile.name => profile
  }
  name    = each.key
  version = each.value["tag"]
  context = each.value["context"]
}
data "spectrocloud_appliances" "this" {
  for_each = { for pool in var.node_pools : pool.name => pool }
  tags     = each.value["edge_host_tags"]
}
resource "spectrocloud_cluster_edge_native" "this" {
  name            = var.name
  tags            = var.cluster_tags
  skip_completion = var.skip_wait_for_completion
  cloud_config {
    ssh_key     = var.ssh_keys
    vip         = var.cluster_vip
    ntp_servers = var.ntp_servers
  }
  location_config {
    latitude  = var.location.latitude
    longitude = var.location.longitude
  }
  dynamic "machine_pool" {
    for_each = var.node_pools
    content {
      name                    = machine_pool.value.name
      control_plane           = machine_pool.value.control_plane
      control_plane_as_worker = machine_pool.value.control_plane == true ? true : false
      additional_labels       = machine_pool.value.pool_labels
      host_uids               = machine_pool.value.edge_host_uid != null ? machine_pool.value.edge_host_uid : data.spectrocloud_appliances.this[machine_pool.value.name].ids
    }
  }
  dynamic "cluster_profile" {
    for_each = var.cluster_profiles
    content {
      id = data.spectrocloud_cluster_profile.this[cluster_profile.value.name].id
      dynamic "pack" {
        for_each = cluster_profile.value.packs == null ? [] : cluster_profile.value.packs
        content {
          name   = pack.value.name
          tag    = pack.value.tag
          values = pack.value.values
        }
      }
    }

  }

  dynamic "cluster_rbac_binding" {
    for_each = var.rbac_bindings
    content {
      type      = cluster_rbac_binding.value.rbac_type
      namespace = cluster_rbac_binding.value.namespace
      role      = cluster_rbac_binding.value.rbac_role

      dynamic "subjects" {
        for_each = cluster_rbac_binding.value.subjects
        content {
          name      = subjects.value.name
          type      = subjects.value.rbac_type
          namespace = subjects.value.namespace
        }
      }
    }
  }

}


