# If looking up a cluster profile instead of creating a new one
# data "spectrocloud_cluster_profile" "profile" {
#   # id = <uid>
#   name = "eks-basic"
# }
#
data "spectrocloud_pack" "aws-ssm-agent" {
  name    = "aws-ssm-agent"
  version = "1.0.0"
}

data "spectrocloud_pack" "spectro-rbac" {
  name    = "spectro-rbac"
  version = "1.0.0"
}

data "spectrocloud_pack" "csi" {
  name    = "csi-aws"
  version = "1.0.0"
}

data "spectrocloud_pack" "cni" {
  name    = "cni-aws-vpc-eks"
  version = "1.0"
}

data "spectrocloud_pack" "k8s" {
  name    = "kubernetes-eks"
  version = "1.19"
}

data "spectrocloud_pack" "ubuntu" {
  name    = "amazon-linux-eks"
  version = "1.0.0"
}

resource "spectrocloud_cluster_profile" "sc" {
  name        = "ProdEKS-1"
  description = "basic eks cp"
  cloud       = "eks"
  type        = "cluster"

  pack {
    name   = data.spectrocloud_pack.ubuntu.name
    tag    = data.spectrocloud_pack.ubuntu.version
    uid    = data.spectrocloud_pack.ubuntu.id
    values = data.spectrocloud_pack.ubuntu.values
  }
  pack {
    name   = data.spectrocloud_pack.k8s.name
    tag    = data.spectrocloud_pack.k8s.version
    uid    = data.spectrocloud_pack.k8s.id
    values = data.spectrocloud_pack.k8s.values
  }

  pack {
    name   = data.spectrocloud_pack.cni.name
    tag    = data.spectrocloud_pack.cni.version
    uid    = data.spectrocloud_pack.cni.id
    values = data.spectrocloud_pack.cni.values
  }

  pack {
    name   = data.spectrocloud_pack.csi.name
    tag    = data.spectrocloud_pack.csi.version
    uid    = data.spectrocloud_pack.csi.id
    values = data.spectrocloud_pack.csi.values
  }

  pack {
    name   = data.spectrocloud_pack.aws-ssm-agent.name
    tag    = data.spectrocloud_pack.aws-ssm-agent.version
    uid    = data.spectrocloud_pack.aws-ssm-agent.id
    values = data.spectrocloud_pack.aws-ssm-agent.values
  }

  pack {
    name   = data.spectrocloud_pack.spectro-rbac.name
    tag    = data.spectrocloud_pack.spectro-rbac.version
    uid    = data.spectrocloud_pack.spectro-rbac.id
    values = "# RBAC Permissions specified at the cluster level"
  }
}

# resource "spectrocloud_cluster_profile" "profile-rbac" {
#   name        = "SC-RBAC"
#   description = "rbac"
#   type        = "add-on"

#   pack {
#     name   = data.spectrocloud_pack.spectro-rbac.name
#     tag    = data.spectrocloud_pack.spectro-rbac.version
#     uid    = data.spectrocloud_pack.spectro-rbac.id
#     values = data.spectrocloud_pack.spectro-rbac.values
#   }
# }
