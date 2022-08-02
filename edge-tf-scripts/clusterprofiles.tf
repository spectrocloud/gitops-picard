data "spectrocloud_registry_oci" "prod-azure" {
  name = "picard-prod-azure"
}

locals {
  cp_files = fileset("${path.module}/config", "profiles-*.yaml")

  cp_list = yamldecode(join("\n", [for i in local.cp_files : file("config/${i}")]))

  cp = {
    for e in local.cp_list :
    e.name => e
  }
}

resource "spectrocloud_cluster_profile" "profile" {
  for_each = local.cp

  name        = each.value.name
  description = try(each.value.description, "")
  tags        = ["dev"]
  type        = "add-on"
  version = each.value.version

  pack {
    name = "manifest-namespace"
    type = "manifest"
    manifest {
      name    = "manifest-namespace"
      content = <<-EOT
        apiVersion: v1
        kind: Namespace
        metadata:
          labels:
            app: wordpress
            app3: wordpress786
          name: wordpress
      EOT
    }
    #uid    = "spectro-manifest-pack"
  }

  dynamic "pack" {
    for_each = each.value.charts
    content {
      name   = pack.value.name
      registry_uid = data.spectrocloud_registry_oci.prod-azure.id
      type   = try(pack.value.type, "spectro")
      tag    = pack.value.version
      values = try(pack.value.values, "")
    }
  }
}
