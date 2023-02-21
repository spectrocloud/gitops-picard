locals {
  edge_files = fileset("${path.module}/config", "edge-stores-*.yaml")

  edge_list = try(yamldecode(join("\n", [for i in local.edge_files : file("config/${i}")])), [])

  edge = {
    for e in local.edge_list :
    e.name => e
  }
}
module "edge" {
  source           = "spectrocloud/edge/spectrocloud"
  version = "1.1.1"
  for_each         = local.edge
  name             = each.value.name
  cluster_tags     = each.value.cluster_tags
  cluster_vip      = each.value.cluster_vip
  node_pools       = each.value.node_pools
  cluster_profiles = each.value.profiles
}