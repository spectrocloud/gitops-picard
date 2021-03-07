# If looking up a cluster profile instead of creating a new one
# data "spectrocloud_cluster_profile" "profile" {
#   # id = <uid>
#   name = var.cluster_cluster_profile_name
# }


resource "spectrocloud_cluster_profile" "prodvmware" {
  name        = "ProdVMware"
  description = "basic cp"
  cloud       = "vsphere"
  type        = "cluster"

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
    name   = "nginx"
    tag    = "0.26.x"
    uid    = data.spectrocloud_pack.nginx-vsphere.id
    values = data.spectrocloud_pack.nginx-vsphere.values
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
