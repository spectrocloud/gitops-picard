locals {
  rbac_yaml    = yamldecode(file("rbac.yaml"))
  rbac_all_crb = lookup(local.rbac_yaml.all_clusters, "clusterRoleBindings", [])
  rbac_all_rb  = lookup(local.rbac_yaml.all_clusters, "namespaces", [])
  rbac_map = {
    for k, v in local.rbac_yaml.clusters :
    k => {
      clusterRoleBindings = concat(local.rbac_all_crb, lookup(v, "clusterRoleBindings", []))
      namespaces        = concat(local.rbac_all_rb, lookup(v, "namespaces", []))
    }
  }
}
