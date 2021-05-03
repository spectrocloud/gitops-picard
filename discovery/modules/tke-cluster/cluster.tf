################################  Clusters   ####################################################

# data "vault_generic_secret" "etcd_encryption_key_px-npe2300" {
#   path = "pe/secret/tke/admin_creds/etcd_encryption_key_px-npe2300"
# }
# resource "vault_generic_secret" "kubeconfig_px-npe2300" {
#   path      = "pe/secret/tke/admin_creds/admin_conf_px-npe2300"
#   data_json = <<-EOT
#     {
#       "kubeconfig" : "${replace(spectrocloud_cluster_vsphere.px-npe2300.kubeconfig, "\n", "\\n")}"
#     }
#   EOT
# }
resource "spectrocloud_cluster_vsphere" "this" {
  name               = local.n
  cluster_profile_id = var.cluster_profile_id
  cloud_account_id   = var.global_config.cloud_account_id
  cloud_config {
    ssh_key    = var.global_config.ssh_public_key
    datacenter = var.global_config.datacenter
    folder     = "${var.global_config.vm_folder}/${local.n}"
    static_ip  = true
  }
  pack {
    name = "kubernetes"
    tag  = var.cluster_packs["k8s"].tag
    values = templatefile(var.cluster_packs["k8s"].file, {
      certSAN: "api-${local.fqdn}",
      issuerURL: "dex.${local.fqdn}",
      etcd_encryption_key: "5BvsKhnGgks5YCNfEGwuo4RkDlBM731YnhFeJr6Z7jE=",
    })
  }
  # TODO
  # etcd_encryption_key : data.vault_generic_secret.etcd_encryption_key_px-npe2300.data["value"] })
  pack {
    name = "dex"
    tag  = var.cluster_packs["dex"].tag
    values = templatefile(var.cluster_packs["dex"].file, {
      issuer: "dex.${local.fqdn}",
    })
  }
  machine_pool {
    control_plane = true
    name          = "master-pool"
    count         = 3

    dynamic "placement" {
      for_each = local.placements
      content {
        cluster           = placement.value.cluster
        resource_pool     = placement.value.resource_pool
        datastore         = placement.value.datastore
        network           = placement.value.network
        static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.api.id
      }
    }
    instance_type {
      disk_size_gb = 60
      memory_mb    = 16384
      cpu          = 4
    }
  }

  dynamic "machine_pool" {
    for_each = ["wp-az1", "wp-az2", "wp-az3"]
    content {
      name = machine_pool.value
      count = var.cluster_workers_per_az
      placement {
        cluster           = local.placements[machine_pool.key].cluster
        resource_pool     = local.placements[machine_pool.key].resource_pool
        datastore         = local.placements[machine_pool.key].datastore
        network           = local.placements[machine_pool.key].network
        static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.workers.id
      }
      instance_type {
        disk_size_gb = 200
        memory_mb    = 131072
        cpu          = 16
      }
    }
  }
}
