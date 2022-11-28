data "spectrocloud_cluster_profile" "this" {
  for_each = {
    for profile in var.cluster_profiles : profile.name => profile
  }
  name    = each.key
  version = each.value["tag"]
}

locals {
  nodes = { for v in flatten([
    for node_pool in var.node_pools : [
      for node in try(node_pool.nodes, []) : {
        name  = node.uid
        value = try(node.labels, {})
      }
    ]
    ]) : v.name => v.value
  }
}
resource "spectrocloud_appliance" "this" {
  for_each = { for k, v in local.nodes : k => v }
  uid      = lower(each.key)
  labels   = each.value
  wait     = false
}

resource "spectrocloud_cluster_edge_native" "this" {
  depends_on      = [spectrocloud_appliance.this]
  name            = var.name
  tags            = var.cluster_tags
  skip_completion = var.skip_wait_for_completion
  cloud_config {
    ssh_key     = var.ssh_keys
    vip         = var.cluster_vip
    ntp_servers = var.ntp_servers
  }
  dynamic "machine_pool" {
    for_each = var.node_pools
    content {
      name                    = machine_pool.value.name
      control_plane           = machine_pool.value.control_plane
      control_plane_as_worker = machine_pool.value.control_plane == true ? true : false
      additional_labels       = machine_pool.value.labels
      host_uids               = machine_pool.value.nodes[*].uid
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
          values = pack.value.values == null ? "" : pack.value.values
        }
      }
    }

  }
}