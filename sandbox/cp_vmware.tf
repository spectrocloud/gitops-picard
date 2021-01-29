# If looking up a cluster profile instead of creating a new one
# data "spectrocloud_cluster_profile" "profile" {
#   # id = <uid>
#   name = var.cluster_cluster_profile_name
# }


data "spectrocloud_pack" "nginx-vsphere" {
  name    = "nginx"
  version = "0.26.1"
}

data "spectrocloud_pack" "hipster-vsphere" {
  name    = "sapp-hipster"
  version = "2.0.0"
}

data "spectrocloud_pack" "lbmetal-vsphere" {
  name    = "lb-metallb"
  version = "0.8.3"
}

data "spectrocloud_pack" "istio-vsphere" {
  name    = "istio"
  version = "1.6.2"
}

data "spectrocloud_pack" "csi-vsphere" {
  name = "csi-vsphere-volume"
  # version  = "1.0.x"
}

data "spectrocloud_pack" "cni-vsphere" {
  name    = "cni-calico"
  version = "3.16.0"
}

data "spectrocloud_pack" "k8s-vsphere" {
  name    = "kubernetes"
  version = "1.18.15"
}

data "spectrocloud_pack" "ubuntu-vsphere" {
  name = "ubuntu-vsphere"
  # version  = "1.0.x"
}

resource "spectrocloud_cluster_profile" "prodvmware" {
  name        = "ProdVMware"
  description = "basic cp"
  cloud       = "vsphere"
  type        = "cluster"

  pack {
    name   = "lb-metallb"
    tag    = "0.9.x"
    uid    = data.spectrocloud_pack.lbmetal-vsphere.id
    values = <<-EOT
      manifests:
        metallb:

          #The namespace to use for deploying MetalLB
          namespace: "metallb-system"

          #MetalLB will skip setting .0 & .255 IP address when this flag is enabled
          avoidBuggyIps: true

          # Layer 2 config; The IP address range MetalLB should use while assigning IP's for svc type LoadBalancer
          # For the supported formats, check https://metallb.universe.tf/configuration/#layer-2-configuration
          addresses:
          - 10.10.182.0-10.10.182.9
    EOT
  }

  pack {
    name   = "sapp-hipster"
    tag    = "2.0.1"
    uid    = data.spectrocloud_pack.hipster-vsphere.id
    values = data.spectrocloud_pack.hipster-vsphere.values
  }

  pack {
    name   = "csi-vsphere-volume"
    tag    = "1.0.x"
    uid    = data.spectrocloud_pack.csi-vsphere.id
    values = data.spectrocloud_pack.csi-vsphere.values
  }

  pack {
    name   = "cni-calico"
    tag    = "3.16.x"
    uid    = data.spectrocloud_pack.cni-vsphere.id
    values = data.spectrocloud_pack.cni-vsphere.values
  }

  pack {
    name   = "kubernetes"
    tag    = "1.18.x"
    uid    = data.spectrocloud_pack.k8s-vsphere.id
    values = data.spectrocloud_pack.k8s-vsphere.values
  }

  pack {
    name   = "ubuntu-vsphere"
    tag    = "LTS__18.4.x"
    uid    = data.spectrocloud_pack.ubuntu-vsphere.id
    values = data.spectrocloud_pack.ubuntu-vsphere.values
  }

}

resource "spectrocloud_cluster_profile" "devvmware" {
  name        = "DevVMware"
  description = "basic cp"
  cloud       = "vsphere"
  type        = "cluster"

  pack {
    name   = "nginx"
    tag    = "0.26.x"
    uid    = data.spectrocloud_pack.nginx-vsphere.id
    values = data.spectrocloud_pack.nginx-vsphere.values
  }

  pack {
    name   = "lb-metallb"
    tag    = "0.8.x"
    uid    = data.spectrocloud_pack.lbmetal-vsphere.id
    values = <<-EOT
      manifests:
        metallb:

          #The namespace to use for deploying MetalLB
          namespace: "metallb-system"

          #MetalLB will skip setting .0 & .255 IP address when this flag is enabled
          avoidBuggyIps: true

          # Layer 2 config; The IP address range MetalLB should use while assigning IP's for svc type LoadBalancer
          # For the supported formats, check https://metallb.universe.tf/configuration/#layer-2-configuration
          addresses:
          - 10.10.182.0-10.10.182.9
    EOT
  }

  pack {
    name   = "csi-vsphere-volume"
    tag    = "1.0.x"
    uid    = data.spectrocloud_pack.csi-vsphere.id
    values = data.spectrocloud_pack.csi-vsphere.values
  }

  pack {
    name   = "cni-calico"
    tag    = "3.16.x"
    uid    = data.spectrocloud_pack.cni-vsphere.id
    values = data.spectrocloud_pack.cni-vsphere.values
  }

  pack {
    name   = "kubernetes"
    tag    = "1.18.x"
    uid    = data.spectrocloud_pack.k8s-vsphere.id
    values = data.spectrocloud_pack.k8s-vsphere.values
  }

  pack {
    name   = "ubuntu-vsphere"
    tag    = "LTS__18.4.x"
    uid    = data.spectrocloud_pack.ubuntu-vsphere.id
    values = data.spectrocloud_pack.ubuntu-vsphere.values
  }

}
