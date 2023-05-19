data "spectrocloud_pack" "vault" {
  name    = "vault"
  version = "0.17.1"
}
data "spectrocloud_pack" "cni-vsphere" {
  name    = "cni-cilium-oss"
  version = "1.12.6"
}
data "spectrocloud_pack" "k8s-vsphere" {
  name    = "kubernetes"
  version = "1.23.9"
}
data "spectrocloud_pack" "dex" {
  name    = "dex"
  version = "2.35.1"
}
data "spectrocloud_pack" "csi-vsphere" {
  name = "csi-vsphere-csi"
  version  = "2.6.0"
}
data "spectrocloud_pack" "ubuntu-vsphere" {
  name = "ubuntu-vsphere"
  version  = "20.04"
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
    tag  = "LTS__20.4.x"
    uid  = data.spectrocloud_pack.ubuntu-vsphere.id
    #values = data.spectrocloud_pack.ubuntu-vsphere.values
    values = file("config/os_ubuntu.yaml")
  }
  pack {
    name   = "kubernetes"
    tag    = "1.23.9"
    uid    = data.spectrocloud_pack.k8s-vsphere.id
    values = data.spectrocloud_pack.k8s-vsphere.values
  }
  pack {
    name   = "cni-cilium-oss"
    tag    = "1.12.6"
    uid    = data.spectrocloud_pack.cni-vsphere.id
    values = data.spectrocloud_pack.cni-vsphere.values
  }
  pack {
    name   = "csi-vsphere-csi"
    tag    = "2.6.x"
    uid    = data.spectrocloud_pack.csi-vsphere.id
    values = data.spectrocloud_pack.csi-vsphere.values
  }
  pack {
    name   = "vault"
    tag    = "0.17.1"
    uid    = data.spectrocloud_pack.vault.id
    values = local.vault_values
  }
  pack {
    name   = "dex"
    tag    = "2.35.1"
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
