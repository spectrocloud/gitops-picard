locals {
  cluster_vmware_files = fileset("${path.module}/config", "cluster-vmware-*.yaml")
  clusters_v = {
    for k in local.cluster_vmware_files :
    trimsuffix(k, ".yaml") => yamldecode(file("config/${k}"))
  }

  cluster_ssh_public_key = <<-EOT
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAUaBODDNpQxJJqXz/Q+afauM5EPFp4oDRrWzK/cGd92N+exkd+tEZdO7n3R+WAx0XTcPiVvfKctzekNS6f/ZMrFb5HAPvFJtnGNIE2sm+eryEnAH+Sc7ppZha3/MaSp/A2dm2IobYRvwl04sEi4w1K+I8Rtt+fBe3gV3wnP3E3yOiRx4G2XFC3T6x8MjdOkjO2v6fBluw1M1H2etp1m/n4D70UkeyVJyipcntz0ubHweU7yPNdNS3YkpExYIGhm97C4dyESHEw9PZVdLs1FBL6mW5Yb4qVbg5FkLljLFynh9jL8IAYal0pibAAH+Sk/Nd4865lVJ3lrm8nhBnjs1OEFA487rcxyInxJk/WwLEHvo88Ku9IlYq15Alr8N/JHHackV4kAH0yJNeLtwAysK2gI7Mb5uGnMTPrz73IZqXSxFqnU34Ow+vwu8fXBtXmHA5cUHyz0ARzpgx8A0e8L8SjdY/6dsFhSzGo7JoCElN7sEMo7iI4Wdo8CYdlT+OXizBf3pnM/wxRZclCeRDJpLtd6jl5swv7J5ocINEh1r3BllCyV8L7Xp5gw8IKT3ohz6rliGJwwlq/emqY52eB3wweTLRm30z3h3aQa3YeAR+2JgvWlrJ3YWsYYCLRhSQTfYmpgUkoZIcfB2xkZzp6cyooM0i5Obz313HsxwBHOmNrw== spectro@spectro
  EOT

}

################################  Clusters   ####################################################

# Create the VMware cluster
resource "spectrocloud_cluster_vsphere" "this" {
  for_each = local.clusters_v
  name     = each.value.name

  cluster_profile {
    id = local.profile_ids[each.value.profiles.infra]

    pack {
      name   = "spectro-rbac"
      tag    = "1.0.0"
      values = <<-EOT
        charts:
          spectro-rbac:
            ${indent(4, replace(yamlencode(each.value.rbac), "/((?:^|\n)[\\s-]*)\"([\\w-]+)\":/", "$1$2:"))}
      EOT
    }
  }

  # cluster_profile {
  #   id = local.profile_ids[each.value.profiles.ehl]
  # }

  cloud_account_id = local.account_ids[each.value.cloud_account]

  cloud_config {
    ssh_key = local.cluster_ssh_public_key

    datacenter = "Datacenter"
    folder     = "Demo/spc-${each.value.name}"

    network_type          = "DDNS"
    network_search_domain = "spectrocloud.local"
  }

  backup_policy {
    schedule                  = each.value.backup_policy.schedule
    backup_location_id        = local.bsl_ids[each.value.backup_policy.backup_location]
    prefix                    = each.value.backup_policy.prefix
    expiry_in_hour            = 7200
    include_disks             = true
    include_cluster_resources = true
  }

  scan_policy {
    configuration_scan_schedule = each.value.scan_policy.configuration_scan_schedule
    penetration_scan_schedule   = each.value.scan_policy.penetration_scan_schedule
    conformance_scan_schedule   = each.value.scan_policy.conformance_scan_schedule
  }

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
      name                    = machine_pool.value.name
      count                   = machine_pool.value.count
      control_plane           = lookup(machine_pool.value, "control_plane", false)
      control_plane_as_worker = lookup(machine_pool.value, "control_plane_as_worker", false)
      dynamic "placement" {
        for_each = machine_pool.value.placements
        content {
          cluster       = placement.value.cluster
          resource_pool = placement.value.resourcepool
          datastore     = placement.value.datastore
          network       = placement.value.network
        }
      }
      instance_type {
        disk_size_gb = machine_pool.value.disk_size_gb
        memory_mb    = machine_pool.value.memory_mb
        cpu          = machine_pool.value.cpu
      }
    }
  }
}