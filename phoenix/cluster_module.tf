locals {
  edge_files = fileset("${path.module}/config", "edge-stores-*.yaml")

  edge_list = try(yamldecode(join("\n", [for i in local.edge_files : file("config/${i}")])), [])

  edge = {
    for e in local.edge_list :
    e.name => e
  }
}
module "edge" {
  source = "./modules"
  for_each         = local.edge
  name             = each.value.name
  skip_wait_for_completion = false
  cluster_tags     = each.value.cluster_tags
  cluster_vip      = each.value.cluster_vip
  node_pools       = each.value.node_pools
  cluster_profiles = each.value.profiles
  location = each.value.location
  rbac_bindings = each.value.rbac_bindings
}