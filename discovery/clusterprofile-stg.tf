data "spectrocloud_pack" "vault-stg" {
  name    = "vault"
  version = "0.17.1"
}
data "spectrocloud_pack" "nginx-stg" {
  name    = "nginx"
  version = "1.2.1"
}
data "spectrocloud_pack" "cni-vsphere-stg" {
  name    = "cni-cilium-oss"
  version = "1.12.6"
}
data "spectrocloud_pack" "k8s-vsphere-stg" {
  name    = "kubernetes"
  version = "1.23.9"
}

data "spectrocloud_pack" "cilium-tetragon" {
  name    = "tetragon"
  version = "0.8.3"
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
    name = "ubuntu-vsphere"
    tag  = "LTS__20.4.x"
    uid  = data.spectrocloud_pack.ubuntu-vsphere.id
    #values = data.spectrocloud_pack.ubuntu-vsphere.values
    values = file("config-stg/os_ubuntu.yaml")
  }
  pack {
    name   = "kubernetes"
    tag    = "1.23.9"
    uid    = data.spectrocloud_pack.k8s-vsphere-stg.id
    values = data.spectrocloud_pack.k8s-vsphere-stg.values
  }
  pack {
    name   = "cni-cilium-oss"
    tag    = "1.12.6"
    uid    = data.spectrocloud_pack.cni-vsphere.id
    values = data.spectrocloud_pack.cni-vsphere.values
  }

  pack {
    name   = "tetragon"
    tag    = "0.8.3"
    uid    = data.spectrocloud_pack.cilium-tetragon.id
    values = data.spectrocloud_pack.cilium-tetragon.values
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
    uid    = data.spectrocloud_pack.vault-stg.id
    values = local.vault_values_stg
  }

  pack {
    name   = "nginx"
    tag    = "1.2.1"
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
    name   = "dex"
    tag    = "2.35.1"
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
