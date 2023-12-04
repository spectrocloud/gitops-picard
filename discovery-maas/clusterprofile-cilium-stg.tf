data "spectrocloud_pack" "os-maas-stg" {
  name    = var.os_name
  version = var.os_version
}
data "spectrocloud_pack" "k8s-maas-stg" {
  name    = var.k8s_name
  version = var.k8s_version
}
data "spectrocloud_pack" "cni-maas-stg" {
  name    = var.cni_name
  version = var.cni_version
}
data "spectrocloud_pack" "csi-maas-stg" {
  name    = var.csi_name
  version = var.csi_version
}
data "spectrocloud_pack" "dex-stg" {
  name    = var.dex_name
  version = var.dex_version
}
data "spectrocloud_pack" "vault-stg" {
  name    = var.vault_name
  version = var.vault_version
}

locals {
  vault_values_stg = replace(
    data.spectrocloud_pack.vault-stg.values,
    "/externalVaultAddr: \"\"/",
    "externalVaultAddr: ${var.vault_address}"
  )
}
resource "spectrocloud_cluster_profile" "tt-prd6001-cilium-stg" {
  name        = "tt-prd6001-cilium-stg"
  description = "MaaS staging Cluster profile"
  cloud       = "maas"
  type        = "cluster"

  pack {
    name = var.os_name
    tag  = var.os_version
    uid  = data.spectrocloud_pack.os-maas-stg.id
    values = file("config-stg/os_ubuntu.yaml")
  }
  pack {
    name   = var.k8s_name
    tag    = var.k8s_version
    uid    = data.spectrocloud_pack.k8s-maas-stg.id
    values = data.spectrocloud_pack.k8s-maas-stg.values
  }
  pack {
    name   = var.cni_name
    tag    = var.cni_version
    uid    = data.spectrocloud_pack.cni-maas-stg.id
    values = data.spectrocloud_pack.cni-maas-stg.values
  }
  pack {
    name   = var.csi_name
    tag    = var.csi_version
    uid    = data.spectrocloud_pack.csi-maas-stg.id
    values = data.spectrocloud_pack.csi-maas-stg.values
  }
  pack {
    name   = var.dex_name
    tag    = var.dex_version
    uid    = data.spectrocloud_pack.dex-stg.id
    values = file("config-stg/dex.yaml")

    manifest {
      name = "dex-config"
      content = templatefile("config-stg/vault-dex.yaml", {
        vault_address : var.vault_address,
        vault_role_id : var.vault_ldap_role_id,
        vault_secret_id : var.vault_ldap_secret_id,
      })
    }
  }
  pack {
    name   = var.vault_name
    tag    = var.vault_version
    uid    = data.spectrocloud_pack.vault-stg.id
    values = local.vault_values_stg
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
      content = file("config-stg/namespace-labeler.yaml")
    }
  }
  pack {
    name = "cred-provider"
    type = "manifest"
    manifest {
      name    = "kubelet-credential-provider"
      content = file("config-stg/cred-provider.yaml")
    }
  }
}
