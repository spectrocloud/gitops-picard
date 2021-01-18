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
  version = "3.16.0"
}

data "spectrocloud_pack" "k8s-gcp" {
  name    = "kubernetes"
  version = "1.18.15"
}

data "spectrocloud_pack" "ubuntu-gcp" {
  name = "ubuntu-gcp"
  # version  = "1.0.x"
}

resource "spectrocloud_cluster_profile" "prod-gcp" {
  name        = "ProdGCP"
  description = "basic cp"
  cloud       = "gcp"
  type        = "cluster"


  pack {
    name   = "csi-gcp"
    tag    = "1.0.x"
    uid    = data.spectrocloud_pack.csi-gcp.id
    values = data.spectrocloud_pack.csi-gcp.values
  }

  pack {
    name   = "cni-calico"
    tag    = "3.16.x"
    uid    = data.spectrocloud_pack.cni-gcp.id
    values = data.spectrocloud_pack.cni-gcp.values
  }

  pack {
    name   = "kubernetes"
    tag    = "1.18.x"
    uid    = data.spectrocloud_pack.k8s-gcp.id
    values = data.spectrocloud_pack.k8s-gcp.values
  }

  pack {
    name   = "ubuntu-gcp"
    tag    = "LTS__18.4.x"
    uid    = data.spectrocloud_pack.ubuntu-gcp.id
    values = data.spectrocloud_pack.ubuntu-gcp.values
  }
}
