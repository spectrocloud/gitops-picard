data "spectrocloud_registry" "bitnami_registry" {
  name = "Bitnami"
}

data "spectrocloud_pack" "multus-cni" {
  name    = var.multus_name
  version = var.multus_version
  type         = "helm"
  registry_uid = data.spectrocloud_registry.bitnami_registry.id
}

data "spectrocloud_pack" "whereabouts" {
  name    = var.whereabouts_name
  version = var.whereabouts_version
  type         = "helm"
  registry_uid = data.spectrocloud_registry.bitnami_registry.id
}

resource "spectrocloud_cluster_profile" "multus-cni-addon" {

  name        = "multus-with-vlan-filtering"
  cloud       = "all"
  description = "Addon profile to setup Multus CNI with VLAN filtering"
  type        = "add-on"

  # Multus CNI from Bitnami registry
  pack {
    name         = data.spectrocloud_pack.multus-cni.name
    registry_uid = data.spectrocloud_registry.bitnami_registry.id
    tag          = data.spectrocloud_pack.multus-cni.version
    type         = "helm"
    values       = file("config-stg-px/multus-1.4.5.yaml")
  }

  # Whereabouts from Bitnami registry
  pack {
    name         = data.spectrocloud_pack.whereabouts.name
    registry_uid = data.spectrocloud_registry.bitnami_registry.id
    tag          = data.spectrocloud_pack.whereabouts.version
    type         = "helm"
    values       = file("config-stg-px/whereabouts.yaml")
  }

  # VLAN filtering manifest
  pack {
    name          = "vlan-filtering"
    type          = "manifest"
    install_order = 0
    manifest {
      name    = "configmap-vlan-filtering"
      content = file("config-stg-px/vlan-filter-cm.yaml")
    }
    manifest {
      name    = "ds-vlan-filtering"
      content = file("config-stg-px/vlan-filter-ds.yaml")
    }
  }

  # Multus Network attachment manifest
  pack {
    name          = "network-attachment-definitions"
    type          = "manifest"
    install_order = 20
    manifest {
      name    = "nad-vlan-200"
      content = file("config-stg-px/multus-network-attachment-vlan.yaml")
    }
  }

}