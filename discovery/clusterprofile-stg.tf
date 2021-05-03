data "spectrocloud_pack" "k8s-vsphere-stg" {
  name    = "kubernetes"
  version = "1.19.7"
}
resource "spectrocloud_cluster_profile" "px-npe2003-stg" {
  name        = "px-npe2003-stg"
  description = "basic cp"
  cloud       = "vsphere"
  type        = "cluster"
  pack {
    name = "ubuntu-vsphere"
    tag  = "LTS__18.4.x"
    uid  = data.spectrocloud_pack.ubuntu-vsphere.id
    #values = data.spectrocloud_pack.ubuntu-vsphere.values
    values = file("config/os_ubuntu-stg.yaml")
  }
  pack {
    name   = "kubernetes"
    tag    = "1.19.7"
    uid    = data.spectrocloud_pack.k8s-vsphere-stg.id
    values = data.spectrocloud_pack.k8s-vsphere-stg.values
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
      content = templatefile("config/dex-vault-stg.yaml", {
        vault_address : var.vault_address,
        vault_role_id : var.vault_ldap_role_id,
        vault_secret_id : var.vault_ldap_secret_id,
      })
    }
  }
}
