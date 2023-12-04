################################  Clusters   ####################################################

# Generate a "stable" random id
resource "random_id" "etcd_encryption_key" {
  byte_length = 32
}

# Create the MaaS cluster
resource "spectrocloud_cluster_maas" "this" {
  
  name = local.n
  cloud_account_id = var.global_config.cloud_account_id.id

  cluster_profile {
    id = var.cluster_profile_id
    pack {
      name = "kubernetes"
      tag  = var.cluster_packs["k8s"].tag
      values = templatefile(var.cluster_packs["k8s"].file, {
        certSAN : "api-${local.fqdn}",
        issuerURL : "dex.${local.fqdn}",
        etcd_encryption_key : random_id.etcd_encryption_key.b64_std
      })
    }
    pack {
      name = "dex"
      tag  = var.cluster_packs["dex"].tag
      values = templatefile(var.cluster_packs["dex"].file, {
        issuer : "dex.${local.fqdn}",
      })
    }
    pack {
      name   = "namespace-labeler"
      tag    = var.cluster_packs["namespace-labeler"].tag
      values = ""
    }
  }

  cloud_config {
    domain = var.maas_domain 
  }

  machine_pool {
    control_plane           = true
    control_plane_as_worker = true
    name                    = "master-pool"
    count                   = 1
    placement {
      resource_pool = var.maas_resource_pool
    }
    instance_type {
      min_memory_mb = 4096
      min_cpu       = 2
    }

    azs = ["default"]
  }

  machine_pool {
    name  = "worker-pool"
    count = var.cluster_workers_per_az

    placement {
      resource_pool = var.maas_resource_pool
    }
    instance_type {
      min_memory_mb = 4096
      min_cpu       = 2
    }

    azs = ["default"]
  }

  timeouts {
    create = 7200
    update = 7200
    delete = 7200
  }

}
