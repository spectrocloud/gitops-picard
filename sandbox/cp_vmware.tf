# If looking up a cluster profile instead of creating a new one
# data "spectrocloud_cluster_profile" "profile" {
#   # id = <uid>
#   name = var.cluster_cluster_profile_name
# }


data "spectrocloud_pack" "nginx-vsphere" {
  name    = "nginx"
  version = "1.3.0"
  registry_uid = data.spectrocloud_registry.registry.id
}

data "spectrocloud_pack" "hipster-vsphere" {
  name    = "sapp-hipster"
  version = "2.0.0"
  registry_uid = data.spectrocloud_registry.registry.id
}

data "spectrocloud_pack" "lbmetal-vsphere" {
  name    = "lb-metallb"
  version = "0.11.0"
  registry_uid = data.spectrocloud_registry.registry.id
}

data "spectrocloud_pack" "istio-vsphere" {
  name    = "istio"
  version = "1.14.1"
  registry_uid = data.spectrocloud_registry.registry.id
}

data "spectrocloud_pack" "csi-vsphere" {
  name    = "csi-vsphere-csi"
  version = "2.6.0"
  registry_uid = data.spectrocloud_registry.registry.id
}

data "spectrocloud_pack" "cni-vsphere" {
  name    = "cni-calico"
  version = "3.19.0"
  registry_uid = data.spectrocloud_registry.registry.id
}

data "spectrocloud_pack" "k8s-vsphere" {
  name    = "kubernetes"
  version = "1.23.9"
  registry_uid = data.spectrocloud_registry.registry.id
}

data "spectrocloud_pack" "ubuntu-vsphere" {
  name    = "ubuntu-vsphere"
  version = "20.04"
  registry_uid = data.spectrocloud_registry.registry.id
}

locals {
  # vsphere_k8s_values = replace(
  #   data.spectrocloud_pack.k8s-vsphere.values,
  #   "/apiServer:\\n\\s+extraArgs:/",
  #   indent(6, "$0\n${local.oidc_args_string}")
  # )

  # vsphere_k8s_values = data.spectrocloud_pack.k8s-vsphere.values
}

resource "spectrocloud_cluster_profile" "prodvmware" {
  name        = "ProdVMware"
  description = "basic cp"
  cloud       = "vsphere"
  type        = "cluster"

  pack {
    name   = data.spectrocloud_pack.ubuntu-vsphere.name
    tag    = data.spectrocloud_pack.ubuntu-vsphere.version
    uid    = data.spectrocloud_pack.ubuntu-vsphere.id
    values = data.spectrocloud_pack.ubuntu-vsphere.values
  }

  pack {
    name   = data.spectrocloud_pack.k8s-vsphere.name
    tag    = data.spectrocloud_pack.k8s-vsphere.version
    uid    = data.spectrocloud_pack.k8s-vsphere.id
    values = file("config/k8s-oidc.yaml")
  }

  pack {
    name   = data.spectrocloud_pack.cni-vsphere.name
    tag    = data.spectrocloud_pack.cni-vsphere.version
    uid    = data.spectrocloud_pack.cni-vsphere.id
    values = data.spectrocloud_pack.cni-vsphere.values
  }

  pack {
    name   = data.spectrocloud_pack.csi-vsphere.name
    tag    = data.spectrocloud_pack.csi-vsphere.version
    uid    = data.spectrocloud_pack.csi-vsphere.id
    values = data.spectrocloud_pack.csi-vsphere.values
  }

  pack {
    name   = data.spectrocloud_pack.lbmetal-vsphere.name
    tag    = data.spectrocloud_pack.lbmetal-vsphere.version
    uid    = data.spectrocloud_pack.lbmetal-vsphere.id
    values = <<-EOT
      pack:
        spectrocloud.com/install-priority: "0"
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
    name   = data.spectrocloud_pack.istio-vsphere.name
    tag    = data.spectrocloud_pack.istio-vsphere.version
    uid    = data.spectrocloud_pack.istio-vsphere.id
    values = data.spectrocloud_pack.istio-vsphere.values
  }

  pack {
    name   = data.spectrocloud_pack.nginx-vsphere.name
    tag    = data.spectrocloud_pack.nginx-vsphere.version
    uid    = data.spectrocloud_pack.nginx-vsphere.id
    values = data.spectrocloud_pack.nginx-vsphere.values
  }

  pack {
    name   = data.spectrocloud_pack.hipster-vsphere.name
    tag    = data.spectrocloud_pack.hipster-vsphere.version
    uid    = data.spectrocloud_pack.hipster-vsphere.id
    values = data.spectrocloud_pack.hipster-vsphere.values
  }

}
