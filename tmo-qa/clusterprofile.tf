data "spectrocloud_pack" "vault" {
  name    = "vault"
  version = "0.11.0"
}
data "spectrocloud_pack" "cni-vsphere" {
  name    = "cni-calico"
  version = "3.19.0"
}
data "spectrocloud_pack" "k8s-vsphere" {
  name    = "kubernetes"
  version = "1.21.6"
}
data "spectrocloud_pack" "dex" {
  name    = "dex"
  version = "2.28.0"
}
data "spectrocloud_pack" "csi-vsphere" {
  name = "csi-vsphere-volume"
  # version  = "1.0.x"
}
data "spectrocloud_pack" "ubuntu-vsphere" {
  name = "ubuntu-vsphere"
  version  = "18.04"
}
locals {
  vault_values = replace(
    data.spectrocloud_pack.vault.values,
    "/externalVaultAddr: \"\"/",
    "externalVaultAddr: ${var.vault_address}"
  )
}
resource "spectrocloud_cluster_profile" "sc-npe" {
  name        = "sc-npe"
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
    tag    = "1.21.6"
    uid    = data.spectrocloud_pack.k8s-vsphere.id
    values = data.spectrocloud_pack.k8s-vsphere.values
  }
  pack {
    name   = "cni-calico"
    tag    = "3.19.x"
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
    tag    = "0.11.0"
    uid    = data.spectrocloud_pack.vault.id
    values = local.vault_values
  }
  pack {
    name   = "dex"
    tag    = "2.28.0"
    uid    = data.spectrocloud_pack.dex.id
    values = file("config/dex.yaml")

    manifest {
      name = "dex-config"
      content = templatefile("config/vault-dex.yaml", {
        vault_address : var.vault_address,
        vault_role_id : var.vault_ldap_role_id,
        vault_secret_id : var.vault_ldap_secret_id,
      })
    }
  }

  pack {
    name = "sc-system"
    type = "manifest"
    manifest {
      name    = "sc-system"
      content = <<-EOT
        apiVersion: v1
        kind: Namespace
        metadata:
          name: sc-system
      EOT
    }
  }

  pack {
    name = "namespace-labeler"
    type = "manifest"
    manifest {
      name = "namespace-label-config"
      content = file("config/namespace-labeler.yaml")
    }
  }
}
