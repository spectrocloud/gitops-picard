locals {
  edge_files = fileset("${path.module}/config", "edge-stores-*.yaml")

  edge_list = yamldecode(join("\n", [for i in local.edge_files: file("config/${i}")]))

  edge = {
    for e in local.edge_list :
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
