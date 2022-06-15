locals {
  # edge_files = fileset("${path.module}/config", "edge-stores-*.yaml")
  edge = {
    for e in yamldecode(file("config/edge-stores.yaml")) :
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
