# If looking up a cluster profile instead of creating a new one
# data "spectrocloud_cluster_profile" "profile" {
#   # id = <uid>
#   name = var.cluster_cluster_profile_name
# }

data "spectrocloud_pack" "csi-gcp" {
  name = "csi-gcp"
  # version  = "1.0.x"
}

data "spectrocloud_pack" "cni-gcp" {
  name    = "cni-calico"
  version = "3.19.0"
}

data "spectrocloud_pack" "k8s-gcp" {
  name    = "kubernetes"
  version = "1.20.14"
}

data "spectrocloud_pack" "ubuntu-gcp" {
  name    = "ubuntu-gcp"
  version = "18.04"
}

locals {
  gcp_k8s_values = replace(
    data.spectrocloud_pack.k8s-gcp.values,
    "/apiServer:\\n\\s+extraArgs:/",
    indent(6, "$0\n${local.oidc_args_string}")
  )
}


resource "spectrocloud_cluster_profile" "prod-gcp" {
  name        = "ProdGCP"
  description = "basic cp"
  cloud       = "gcp"
  type        = "cluster"


  pack {
    name   = data.spectrocloud_pack.ubuntu-gcp.name
    tag    = data.spectrocloud_pack.ubuntu-gcp.version
    uid    = data.spectrocloud_pack.ubuntu-gcp.id
    values = data.spectrocloud_pack.ubuntu-gcp.values
  }

  pack {
    name   = data.spectrocloud_pack.k8s-gcp.name
    tag    = data.spectrocloud_pack.k8s-gcp.version
    uid    = data.spectrocloud_pack.k8s-gcp.id
    values = local.gcp_k8s_values
  }

  pack {
    name   = data.spectrocloud_pack.cni-gcp.name
    tag    = data.spectrocloud_pack.cni-gcp.version
    uid    = data.spectrocloud_pack.cni-gcp.id
    values = data.spectrocloud_pack.cni-gcp.values
  }

  pack {
    name   = "csi-gcp"
    tag    = "1.0.x"
    uid    = data.spectrocloud_pack.csi-gcp.id
    values = data.spectrocloud_pack.csi-gcp.values
  }

}
