locals {
  edge_files = fileset("edge-stores", "edge-stores-*.yaml")

  edge_list = try(yamldecode(join("\n", [for i in local.edge_files : file("edge-stores/${i}")])), [])

  edge = {
    for e in local.edge_list :
    e.name => e
  }
}

resource "null_resource" "python_dependencies" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "pip install -r modules/edge/requirements.txt"
  }
}

module "edge" {
  depends_on = [null_resource.python_dependencies]

  source                   = "./modules/edge"
  for_each                 = local.edge
  name                     = each.value.name
  skip_wait_for_completion = false
  cluster_tags             = each.value.cluster_tags
  cluster_vip              = each.value.cluster_vip
  node_pools               = each.value.node_pools
  cluster_profiles         = each.value.profiles
  location                 = each.value.location
  rbac_bindings            = each.value.rbac_bindings
}
