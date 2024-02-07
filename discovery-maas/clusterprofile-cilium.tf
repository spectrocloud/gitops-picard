data "spectrocloud_pack" "os-maas" {
  name    = var.os_name
  version = var.os_version
}
data "spectrocloud_pack" "k8s-maas" {
  name    = var.k8s_name
  version = var.k8s_version
}
data "spectrocloud_pack" "cni-maas" {
  name    = var.cni_name
  version = var.cni_version
}
data "spectrocloud_pack" "csi-maas" {
  name    = var.csi_name
  version = var.csi_version
}
data "spectrocloud_pack" "dex" {
  name    = var.dex_name
  version = var.dex_version
}
data "spectrocloud_pack" "vault" {
  name    = var.vault_name
  version = var.vault_version
}

locals {
  vault_values = replace(
    data.spectrocloud_pack.vault.values,
    "/externalVaultAddr: \"\"/",
    "externalVaultAddr: ${var.vault_address}"
  )
}
resource "spectrocloud_cluster_profile" "tt-prd6001-cilium" {
  name        = "tt-prd6001-cilium"
  description = "MaaS staging Cluster profile"
  cloud       = "maas"
  type        = "cluster"

  pack {
    name   = var.os_name
    tag    = var.os_version
    uid    = data.spectrocloud_pack.os-maas.id
    values = file("config/os_ubuntu.yaml")
  }
  pack {
    name   = var.k8s_name
    tag    = var.k8s_version
    uid    = data.spectrocloud_pack.k8s-maas.id
    values = data.spectrocloud_pack.k8s-maas.values
  }
  pack {
    name   = var.cni_name
    tag    = var.cni_version
    uid    = data.spectrocloud_pack.cni-maas.id
    values = data.spectrocloud_pack.cni-maas.values
  }
  pack {
    name   = var.csi_name
    tag    = var.csi_version
    uid    = data.spectrocloud_pack.csi-maas.id
    values = data.spectrocloud_pack.csi-maas.values
  }
  pack {
    name   = var.dex_name
    tag    = var.dex_version
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
    name   = var.vault_name
    tag    = var.vault_version
    uid    = data.spectrocloud_pack.vault.id
    values = local.vault_values
  }
  pack {
    name = "tke-system"
    type = "manifest"
    manifest {
      name    = "tke-system"
      content = <<-EOT
        apiVersion: v1
        kind: Namespace
        metadata:
          name: tke-system
      EOT
    }
  }
  pack {
    name = "namespace-labeler"
    type = "manifest"
    manifest {
      name    = "namespace-label-config"
      content = file("config/namespace-labeler.yaml")
    }
  }
  pack {
    name = "cred-provider"
    type = "manifest"
    manifest {
      name    = "kubelet-credential-provider"
      content = file("config/cred-provider.yaml")
    }
  }
}
