# If looking up a cluster profile instead of creating a new one
# data "spectrocloud_cluster_profile" "profile" {
#   # id = <uid>
#   name = var.cluster_cluster_profile_name
# }


# data "spectrocloud_pack" "nginx-maas" {
#   name    = "nginx"
#   version = "0.43.0"
# }

# data "spectrocloud_pack" "hipster-maas" {
#   name    = "sapp-hipster"
#   version = "2.0.0"
# }

# data "spectrocloud_pack" "lbmetal-maas" {
#   name    = "lb-metallb"
#   version = "0.8.3"
# }

# data "spectrocloud_pack" "istio-maas" {
#   name    = "istio"
#   version = "1.6.2"
# }

data "spectrocloud_pack" "csi-maas" {
  name = "csi-maas-volume"
  # version  = "1.0.x"
}

data "spectrocloud_pack" "cni-maas" {
  name    = "cni-calico"
  version = "3.16.0"
}

data "spectrocloud_pack" "k8s-maas" {
  name    = "kubernetes"
  version = "1.18.15"
}

data "spectrocloud_pack" "ubuntu-maas" {
  name = "ubuntu-maas"
  # version  = "1.0.x"
}

locals {
  maas_k8s_values = replace(
    data.spectrocloud_pack.k8s-maas.values,
    "/apiServer:\\n\\s+extraArgs:/",
    indent(6, "$0\n${local.oidc_args_string}")
  )
}

resource "spectrocloud_cluster_profile" "prodmaas" {
  name        = "Prodmaas"
  description = "basic cp"
  cloud       = "maas"
  type        = "cluster"

  pack {
    name   = "ubuntu-maas"
    tag    = "LTS__18.4.x"
    uid    = data.spectrocloud_pack.ubuntu-maas.id
    values = data.spectrocloud_pack.ubuntu-maas.values
  }

  pack {
    name   = "kubernetes"
    tag    = "1.18.15"
    uid    = data.spectrocloud_pack.k8s-maas.id
    values = local.maas_k8s_values
  }

  pack {
    name   = "cni-calico"
    tag    = "3.16.x"
    uid    = data.spectrocloud_pack.cni-maas.id
    values = data.spectrocloud_pack.cni-maas.values
  }

  pack {
    name   = "csi-maas-volume"
    tag    = "1.0.x"
    uid    = data.spectrocloud_pack.csi-maas.id
    values = data.spectrocloud_pack.csi-maas.values
  }

}

