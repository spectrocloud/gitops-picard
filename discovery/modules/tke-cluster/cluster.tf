################################  Clusters   ####################################################

locals {
  public_key_openssh = tls_private_key.ssh_key.public_key_openssh
  private_key_pem    = tls_private_key.ssh_key.private_key_pem
}

# Generate a "stable" random id
resource "random_id" "etcd_encryption_key" {
  byte_length = 32
}

# Generate SSH keys for the nodes
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  #rsa_bits  = 4096 # Defaults to 2048 bit
}

# Create the VMware cluster
resource "spectrocloud_cluster_vsphere" "this" {
  name             = local.n
  cloud_account_id = var.global_config.cloud_account_id

  cluster_profile {
    id = var.cluster_profile_id

    pack {
      name = "kubernetes"
      tag = var.cluster_packs["k8s"].tag
      values = templatefile(var.cluster_packs["k8s"].file, {
        certSAN : "api-${local.fqdn}",
        issuerURL : "dex.${local.fqdn}",
        etcd_encryption_key : random_id.etcd_encryption_key.b64_std
      })
    }

    pack {
      name = "dex"
      tag = var.cluster_packs["dex"].tag
      values = templatefile(var.cluster_packs["dex"].file, {
        issuer : "dex.${local.fqdn}",
      })
    }

    pack {
      name = "namespace-labeler"
      tag = var.cluster_packs["namespace-labeler"].tag
      values = ""
    }
  }

  cloud_config {
    ssh_key    = local.public_key_openssh
    datacenter = var.global_config.datacenter
    folder     = "${var.vm_folder}/${local.n}"
    static_ip  = true
    #ntp_servers = ["time.nist.gov","time.google.com"]
  }

  machine_pool {
    control_plane = true
    name          = "master-pool"
    count         = 1
    #additional_labels = {
      #"k8s.t-mobile.com/cmdb_app_id" = "APP0005963",
      #"k8s.t-mobile.com/cmdb_app" = "TKE-test"
    #}

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
    for_each = ["wp-az1","wp-az2","wp-az3"]
    content {
      name  = machine_pool.value
      additional_labels = {
        "k8s.t-mobile.com/cmdb_app_id" = "APP0005963"
      }
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

  dynamic "machine_pool" {
    # Conditionally include additional worker pool resources. When count is 0, resource will not be created
    for_each = var.cluster_worker1_start_ip != "" ? ["wp-az1-1", "wp-az2-1", "wp-az3-1"] : []
    content {
      name  = machine_pool.value
      count = var.cluster_workers1_per_az
      placement {
        cluster           = local.placements[machine_pool.key].cluster
        resource_pool     = local.placements[machine_pool.key].resource_pool
        datastore         = local.placements[machine_pool.key].datastore
        network           = local.placements[machine_pool.key].network
        static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.workers1[0].id
      }
      instance_type {
        disk_size_gb = var.global_config.worker_node.disk_gb
        memory_mb    = var.global_config.worker_node.memory_mb
        cpu          = var.global_config.worker_node.cpu
      }
    }
  }
}
