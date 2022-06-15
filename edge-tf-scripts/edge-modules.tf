locals {
  edge_files = fileset("${path.module}/config", "edge-stores-*.yaml")

  edgeList = flatten([for k in local.edge_files : [for e in yamldecode(file("config/${k}")) : e]])
  edge = {
    for e in local.edgeList :
      e.name => e
  }
}

module "edge" {
  source = "./modules/edge"
  for_each = local.edge

  name = each.value.name
  tags = each.value.tags

  # Device UUIDs to be added
  device_uuid = each.value.edge_servers

  # Profiles to be added
  cluster_profiles = each.value.profiles
}
