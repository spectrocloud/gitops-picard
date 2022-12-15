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
# resource "spectrocloud_appliance" "this" {
#   for_each = { for k, v in local.nodes : k => v }
#   uid      = lower(each.key)
#   labels   = each.value
#   wait     = false
# }

resource "spectrocloud_cluster_maas" "cluster" {
  name            = var.name
  tags            = var.cluster_tags

  cloud_account_id = "62166854f62df85d6cf9bd9d"
  #skip_completion = var.skip_wait_for_completion
  cloud_config {
    domain = "maas.sc"
  }

  dynamic "machine_pool" {
    for_each = var.node_pools
    content {
      name                    = machine_pool.value.name
      control_plane           = machine_pool.value.control_plane
      control_plane_as_worker = machine_pool.value.control_plane == true ? true : false
      count = machine_pool.value.count

      placement {
        resource_pool = machine_pool.value.resource_pool
      }

      instance_type {
        min_memory_mb = 4096
        min_cpu       = 2
      }

      azs = ["az1", "az2", "az3"]
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
