data "spectrocloud_registry" "Bitnami_registry" {
  name = "Bitnami"
}

data "spectrocloud_pack_simple" "redis_pack" {
  type         = "helm"
  name         = "redis"
  version      = "17.11.3"
  registry_uid = data.spectrocloud_registry.Bitnami_registry.id
}

resource "spectrocloud_cluster_profile" "profile_resource" {
  cloud       = "eks"
  description = "addon-profile-1"
  name        = "addon-profile-1"
  type        = "add-on"

  pack {
    name         = data.spectrocloud_pack_simple.redis_pack.name
    registry_uid = data.spectrocloud_registry.Bitnami_registry.id
    tag          = data.spectrocloud_pack_simple.redis_pack.version
    uid          = data.spectrocloud_pack_simple.redis_pack.id
    type         = "helm"
    values       = <<-EOT
                   pack:
                     namespace: "redis"
                     spectrocloud.com/install-priority: "230"
                     releaseNameOverride:
                       redis-service: redis-service-name
               EOT
  }
}

resource "spectrocloud_addon_deployment" "depl" {
  cluster_uid = module.tool-dev-1.cluster_id

  cluster_profile {
    id = spectrocloud_cluster_profile.profile_resource.id
    pack {
      name         = data.spectrocloud_pack_simple.redis_pack.name
      type         = "helm"
      registry_uid = data.spectrocloud_registry.Bitnami_registry.id
      tag          = data.spectrocloud_pack_simple.redis_pack.version
      uid          = data.spectrocloud_pack_simple.redis_pack.id
      values = <<-EOT
      pack:
        namespace: "redis"
        spectrocloud.com/install-priority: "230"
        releaseNameOverride:
          redis-service: redis-service-name
    EOT
    }
  }
}
