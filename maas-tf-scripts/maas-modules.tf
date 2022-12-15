locals {
  maas_files = fileset("${path.module}/config", "cluster-*.yaml")

  maas_list = try(yamldecode(join("\n", [for i in local.maas_files : file("config/${i}")])), [])

  maas = {
    for e in local.maas_list :
    e.name => e
  }
}
module "edge" {
  source           = "./modules/maas"
  for_each         = local.maas
  name             = each.value.name
  cluster_tags     = each.value.cluster_tags
  node_pools       = each.value.node_pools
  cluster_profiles = each.value.profiles
}
