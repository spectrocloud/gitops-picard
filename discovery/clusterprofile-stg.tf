data "spectrocloud_pack" "vault-stg" {
  name    = var.vault_name
  version = var.vault_version
}
data "spectrocloud_pack" "nginx-stg" {
  name    = var.nginx_name
  version = var.nginx_version
}
data "spectrocloud_pack" "cni-vsphere-stg" {
  name    = var.cni_name
  version = var.cni_version
}
data "spectrocloud_pack" "k8s-vsphere-stg" {
  name    = var.k8s_name
  version = var.k8s_version
}
data "spectrocloud_pack" "os-vsphere-stg" {
  name    = var.os_name
  version = var.os_version_20_04
}
data "spectrocloud_pack" "cilium-tetragon" {
  name    = var.tetragon_name
  version = var.tetragon_version
}
locals {
  vault_values_stg = replace(
    data.spectrocloud_pack.vault-stg.values,
    "/externalVaultAddr: \"\"/",
    "externalVaultAddr: ${var.vault_address}"
  )
}
resource "spectrocloud_cluster_profile" "sc-npe-stg" {
  name        = "sc-npe-stg"
  description = "basic cp"
  cloud       = "vsphere"
  type        = "cluster"
  pack {
    name = var.os_name
    tag  = var.os_version_20_04
    uid  = data.spectrocloud_pack.os-vsphere-stg.id
    #values = data.spectrocloud_pack.ubuntu-vsphere.values
    values = file("config-stg/os_ubuntu.yaml")
  }
  pack {
    name   = var.k8s_name
    tag    = var.k8s_version
    uid    = data.spectrocloud_pack.k8s-vsphere-stg.id
    values = data.spectrocloud_pack.k8s-vsphere-stg.values
  }
  pack {
    name   = var.cni_name
    tag    = var.cni_version
    uid    = data.spectrocloud_pack.cni-vsphere.id
    values = data.spectrocloud_pack.cni-vsphere.values
  }

  pack {
    name   = var.tetragon_name
    tag    = var.tetragon_version
    uid    = data.spectrocloud_pack.cilium-tetragon.id
    values = data.spectrocloud_pack.cilium-tetragon.values
  }
  pack {
    name   = var.csi_name
    tag    = var.csi_version
    uid    = data.spectrocloud_pack.csi-vsphere.id
    values = data.spectrocloud_pack.csi-vsphere.values
  }
  pack {
    name   = var.vault_name
    tag    = var.vault_version
    uid    = data.spectrocloud_pack.vault-stg.id
    values = local.vault_values_stg
  }

  pack {
    name   = var.nginx_name
    tag    = var.nginx_version
    uid    = data.spectrocloud_pack.nginx-stg.id
    values = file("config-stg/nginx.yaml")

    manifest {
      name = "nginx-config"
      content = templatefile("config-stg/nginx-config.yaml", {
        # Read actual cert, key details from file and base64 encode using filebase64 function
        # This should be updated whenever we change the certs
        tls_key_contents : filebase64("config-stg/certs/sc-npe.key"),
        tls_crt_contents : filebase64("config-stg/certs/sc-npe.crt"),
        ca_crt_contents : filebase64("config-stg/certs/ca.crt"),
      })
    }
  }

  pack {
    name   = var.dex_name
    tag    = var.dex_version
    uid    = data.spectrocloud_pack.dex.id
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
      content = file("config-stg/namespace-labeler.yaml")
    }
  }
}
