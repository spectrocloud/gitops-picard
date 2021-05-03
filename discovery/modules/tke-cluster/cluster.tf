################################  Clusters   ####################################################

# Generate a "stable" random id
resource "random_id" "etcd_encryption_key" {
  byte_length = 32
}

# Create the VMware cluster
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
      etcd_encryption_key: random_id.etcd_encryption_key.b64_std
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
      disk_size_gb = var.global_config.api_node.disk_gb
      memory_mb    = var.global_config.api_node.memory_mb
      cpu          = var.global_config.api_node.cpu
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
        disk_size_gb = var.global_config.worker_node.disk_gb
        memory_mb    = var.global_config.worker_node.memory_mb
        cpu          = var.global_config.worker_node.cpu
      }
    }
  }
}
