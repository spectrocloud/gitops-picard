# If looking up a cluster profile instead of creating a new one
# data "spectrocloud_cluster_profile" "profile" {
#   # id = <uid>
#   name = var.cluster_cluster_profile_name
# }


locals {
  nginx_default_tls = <<-EOT
    extraArgs:
      default-ssl-certificate: "nginx/default-tls"
  EOT
  nginx_values = replace(
    data.spectrocloud_pack.nginx-vsphere.values,
    "/##   default-ssl-certificate: \"<namespace>/<secret_name>\"\\n\\s+extraArgs: {}\\n/",
    indent(6, local.nginx_default_tls)
  )
}

resource "spectrocloud_cluster_profile" "ifcvmware" {
  name        = "IFCVMware"
  description = "basic cp"
  cloud       = "vsphere"
  type        = "cluster"

  # Not in T-Mo
  pack {
    name   = "lb-metallb"
    tag    = "0.9.5"
    uid    = data.spectrocloud_pack.lbmetal-vsphere.id
    values    = data.spectrocloud_pack.lbmetal-vsphere.values
  }

  pack {
    name   = "nginx"
    tag    = "0.43.0"
    uid    = data.spectrocloud_pack.nginx-vsphere.id
    values = local.nginx_values
  }

  pack {
    name   = "spectro-byo-manifest"
    tag    = "1.0.0"
    uid    = data.spectrocloud_pack.byom.id
    values = <<-EOT
      manifests:
        byo-manifest:
          contents: |
            apiVersion: v1
            kind: Secret
            metadata:
              name: ldap-secret
              namespace: dex
            data:
              bindpw: QWJjMTIzNDUh
    EOT
  }

  pack {
    name   = "dex"
    tag    = "2.25.0"
    uid    = data.spectrocloud_pack.dex.id
    values = data.spectrocloud_pack.dex.values
    # values = templatefile("dex_config.yaml", {})
  }

  pack {
    name   = "csi-vsphere-volume"
    tag    = "1.0.x"
    uid    = data.spectrocloud_pack.csi-vsphere.id
    values = <<-EOT
      manifests:
        vsphere:

          #DiskFormat types : thin, zeroedthick and eagerzeroedthick
          diskformat: "thin"

          #If specified, the volume will be created on the datastore specified in the storage class.
          #This field is optional. If the datastore is not specified, then the volume will be created
          # on the datastore specified in the vSphere config file used to initialize the vSphere Cloud Provider.
          datastore: ""

          #Toggle for Default class
          isDefaultClass: "true"

          #Supported binding modes are Immediate, WaitForFirstConsumer
          volumeBindingMode: "WaitForFirstConsumer"
    EOT
  }

  pack {
    name   = "cni-calico"
    tag    = "3.16.x"
    uid    = data.spectrocloud_pack.cni-vsphere.id
    values = data.spectrocloud_pack.cni-vsphere.values
  }

  # This becomes modified in T-Mo with a hardcoded issuer
  pack {
    name   = "kubernetes"
    tag    = "1.18.15"
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
