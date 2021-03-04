# If looking up a cluster profile instead of creating a new one
# data "spectrocloud_cluster_profile" "profile" {
#   # id = <uid>
#   name = var.cluster_cluster_profile_name
# }


resource "spectrocloud_cluster_profile" "ifcvmware" {
  name        = "IFCVMware"
  description = "basic cp"
  cloud       = "vsphere"
  type        = "cluster"

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
    values = templatefile("dex_config.yaml", {})
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

  pack {
    name   = "kubernetes"
    tag    = "1.18.13"
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
