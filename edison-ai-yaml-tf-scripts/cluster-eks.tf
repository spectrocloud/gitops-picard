locals {
  cluster_files = fileset("${path.module}/config", "cluster-eks-*.yaml")
  clusters = {
    for k in local.cluster_files :
    trimsuffix(k, ".yaml") => yamldecode(file("config/${k}"))
  }

  # rbac_yaml    = yamldecode(file("rbac.yaml"))
  # rbac_all_crb = lookup(local.rbac_yaml.all_clusters, "clusterRoleBindings", [])
  # rbac_all_rb  = lookup(local.rbac_yaml.all_clusters, "namespaces", [])
  # rbac_all_crb = lookup(local.rbac_yaml.all_clusters, "clusterRoleBindings", [])
  # rbac_all_rb  = lookup(local.rbac_yaml.all_clusters, "namespaces", [])
  #
  # rbac_map = {
  #   for k, v in local.rbac_yaml.clusters :
  #   k => {
  #     clusterRoleBindings = concat(local.rbac_all_crb, lookup(v, "clusterRoleBindings", []))
  #     namespaces        = concat(local.rbac_all_rb, lookup(v, "namespaces", []))
  #   }
  # }
}

################################  Clusters   ####################################################

# Create the VMware cluster
resource "spectrocloud_cluster_eks" "this" {
  for_each = local.clusters
  name     = each.value.name

  cluster_profile {
    id = local.profile_ids[each.value.profiles.infra]

    # pack {
    #   name   = "spectro-rbac"
    #   tag    = "1.0.0"
    #   values = <<-EOT
    #     charts:
    #       spectro-rbac:
    #         ${indent(4, replace(yamlencode(each.value.rbac), "/((?:^|\n)[\\s-]*)\"([\\w-]+)\":/", "$1$2:"))}
    #   EOT
    # }
  }

  # cluster_profile {
  #   id = local.profile_ids[each.value.profiles.ehl]
  # }

  cloud_account_id = local.account_ids[each.value.cloud_account]

  cloud_config {
    # ssh_key_name = var.cluster_ssh_public_key_name
    region              = each.value.cloud_config.aws_region
    vpc_id              = each.value.cloud_config.aws_vpc_id
    az_subnets          = each.value.cloud_config.eks_subnets
    azs                 = []
    public_access_cidrs = []
  }

  scan_policy {
    configuration_scan_schedule = each.value.scan_policy.configuration_scan_schedule
    penetration_scan_schedule   = each.value.scan_policy.penetration_scan_schedule
    conformance_scan_schedule   = each.value.scan_policy.conformance_scan_schedule
  }

  # backup_policy {
  #   schedule                  = each.value.backup_policy.schedule
  #   backup_location_id        = local.bsl_ids[each.value.backup_policy.backup_location]
  #   prefix                    = each.value.backup_policy.prefix
  #   expiry_in_hour            = 7200
  #   include_disks             = true
  #   include_cluster_resources = true
  # }

  # pack {
  #   name = "kubernetes"
  #   tag  = var.cluster_packs["k8s"].tag
  #   values = templatefile(var.cluster_packs["k8s"].file, {
  #     certSAN: "api-${local.fqdn}",
  #     issuerURL: "dex.${local.fqdn}",
  #     etcd_encryption_key: random_id.etcd_encryption_key.b64_std
  #   })
  # }

  dynamic "machine_pool" {
    for_each = each.value.node_groups
    content {
      name          = machine_pool.value.name
      count         = machine_pool.value.count
      instance_type = machine_pool.value.instance_type
      az_subnets    = machine_pool.value.worker_subnets
      disk_size_gb  = machine_pool.value.disk_size_gb
      azs           = []
    }
  }
  # dynamic "fargate_profile" {
  #   for_each = each.value.fargate_profiles
  #   content {
  #     name            = fargate_profile.value.name
  #     subnets         = fargate_profile.value.subnets
  #     additional_tags = fargate_profile.value.additional_tags
  #     dynamic "selector" {
  #       for_each = fargate_profile.value.selectors
  #       content {
  #         namespace = selector.value.namespace
  #         labels    = selector.value.labels
  #       }
  #     }
  #   }
  # }
}
