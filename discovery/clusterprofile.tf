data "spectrocloud_pack" "vault" {
  name    = "vault"
  version = "0.9.0"
}
data "spectrocloud_pack" "dex" {
  name    = "dex"
  version = "2.28.0"
}
# data "spectrocloud_pack" "byom" {
#   name    = "spectro-byo-manifest"
#   version = "1.0.0"
# }
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
  version = "1.19.7"
}
data "spectrocloud_pack" "ubuntu-vsphere" {
  name = "ubuntu-vsphere"
  # version  = "1.0.x"
}
locals {
  vault_values = replace(
    data.spectrocloud_pack.vault.values,
    "/externalVaultAddr: \"\"/",
    "externalVaultAddr: ${var.vault_address}"
  )
}
resource "spectrocloud_cluster_profile" "px-npe2003" {
  name        = "px-npe2003"
  description = "basic cp"
  cloud       = "vsphere"
  type        = "cluster"
  pack {
    name = "ubuntu-vsphere"
    tag  = "LTS__18.4.x"
    uid  = data.spectrocloud_pack.ubuntu-vsphere.id
    #values = data.spectrocloud_pack.ubuntu-vsphere.values
    values = file("config/os_ubuntu.yaml")
  }
  pack {
    name   = "kubernetes"
    tag    = "1.19.7"
    uid    = data.spectrocloud_pack.k8s-vsphere.id
    values = data.spectrocloud_pack.k8s-vsphere.values
  }
  pack {
    name   = "cni-calico"
    tag    = "3.16.x"
    uid    = data.spectrocloud_pack.cni-vsphere.id
    values = data.spectrocloud_pack.cni-vsphere.values
  }
  pack {
    name   = "csi-vsphere-volume"
    tag    = "1.0.x"
    uid    = data.spectrocloud_pack.csi-vsphere.id
    values = <<-EOT
      manifests:
        vsphere:
          #DiskFormat types : thin, zeroedthick and eagerzeroedthick
          diskformat: "eagerzeroedthick"
          #If specified, the volume will be created on the datastore specified in the storage class.
          #This field is optional. If the datastore is not specified, then the volume will be created
          # on the datastore specified in the vSphere config file used to initialize the vSphere Cloud Provider.
          datastore: ""
          #Toggle for Default class
          isDefaultClass: "false"
          #Supported binding modes are Immediate, WaitForFirstConsumer
          volumeBindingMode: "Immediate"
    EOT
  }
  pack {
    name   = "vault"
    tag    = "0.9.0"
    uid    = data.spectrocloud_pack.vault.id
    values = local.vault_values
  }
  pack {
    name   = "dex"
    tag    = "2.28.0"
    uid    = data.spectrocloud_pack.dex.id
    values = file("config/dex-stg.yaml")
    manifest {
      name = "dex-config"
      content = templatefile("config/dex-vault.yaml", {
        vault_address : var.vault_address,
        vault_role_id : var.vault_ldap_role_id,
        vault_secret_id : var.vault_ldap_secret_id,
      })
    }
  }
}
