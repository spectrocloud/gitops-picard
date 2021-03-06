# If looking up a cluster profile instead of creating a new one
# data "spectrocloud_cluster_profile" "profile" {
#   # id = <uid>
#   name = var.cluster_cluster_profile_name
# }

data "spectrocloud_pack" "csi-azure" {
  name = "csi-azure"
  # version  = "1.0.x"
}

data "spectrocloud_pack" "cni-azure" {
  name    = "cni-calico-azure"
  version = "3.16.0"
}

data "spectrocloud_pack" "k8s-azure" {
  name    = "kubernetes"
  version = "1.18.15"
}

data "spectrocloud_pack" "ubuntu-azure" {
  name = "ubuntu-azure"
  # version  = "1.0.x"
}

locals {
  azure_k8s_values = replace(
    data.spectrocloud_pack.k8s-azure.values,
    "/apiServer:\\n\\s+extraArgs:/",
    indent(6, "$0\n${local.oidc_args_string}")
  )
}

resource "spectrocloud_cluster_profile" "azure" {
  name        = "ProdAzure"
  description = "basic cp"
  cloud       = "azure"
  type        = "cluster"

  pack {
    name   = "ubuntu-azure"
    tag    = "LTS__18.4.x"
    uid    = data.spectrocloud_pack.ubuntu-azure.id
    values = data.spectrocloud_pack.ubuntu-azure.values
  }

  pack {
    name   = "kubernetes"
    tag    = "1.18.15"
    uid    = data.spectrocloud_pack.k8s-azure.id
    values = local.azure_k8s_values
  }

  pack {
    name   = "cni-calico-azure"
    tag    = "3.16.x"
    uid    = data.spectrocloud_pack.cni-azure.id
    values = data.spectrocloud_pack.cni-azure.values
  }

  pack {
    name   = "csi-azure"
    tag    = "1.0.x"
    uid    = data.spectrocloud_pack.csi-azure.id
    values = data.spectrocloud_pack.csi-azure.values
  }



}
