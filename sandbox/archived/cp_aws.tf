# If looking up a cluster profile instead of creating a new one
# data "spectrocloud_cluster_profile" "profile" {
#   # id = <uid>
#   name = var.cluster_cluster_profile_name
# }

data "spectrocloud_pack" "csi-aws" {
  name = "csi-aws"
  # version  = "1.0.x"
}

data "spectrocloud_pack" "cni-aws" {
  name    = "cni-calico"
  version = "3.16.0"
}

data "spectrocloud_pack" "k8s-aws" {
  name    = "kubernetes"
  version = "1.18.16"
}

data "spectrocloud_pack" "ubuntu-aws" {
  name = "ubuntu-aws"
  # version  = "1.0.x"
}

locals {
  aws_k8s_values = replace(
    data.spectrocloud_pack.k8s-aws.values,
    "/apiServer:\\n\\s+extraArgs:/",
    indent(6, "$0\n${local.oidc_args_string}")
  )
}

resource "spectrocloud_cluster_profile" "prodaws" {
  name        = "ProdAWS"
  description = "basic cp"
  cloud       = "aws"
  type        = "cluster"


  pack {
    name   = "ubuntu-aws"
    tag    = "LTS__18.4.x"
    uid    = data.spectrocloud_pack.ubuntu-aws.id
    values = file("config/os_ubuntu.yaml")
  }

  pack {
    name   = "kubernetes"
    tag    = "1.18.16"
    uid    = data.spectrocloud_pack.k8s-aws.id
    values = local.aws_k8s_values
  }

  pack {
    name   = "cni-calico"
    tag    = "3.16.x"
    uid    = data.spectrocloud_pack.cni-aws.id
    values = data.spectrocloud_pack.cni-aws.values
  }

  pack {
    name   = "csi-aws"
    tag    = "1.0.x"
    uid    = data.spectrocloud_pack.csi-aws.id
    values = data.spectrocloud_pack.csi-aws.values
  }
}

