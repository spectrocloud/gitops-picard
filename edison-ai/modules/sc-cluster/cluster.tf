################################  Clusters   ####################################################

# Create the VMware cluster
resource "spectrocloud_cluster_eks" "this" {
  name = local.n
  cluster_profile {
    id = var.cluster_profile_id
    # pack {
    #   name   = "spectro-rbac"
    #   tag    = "1.0.0"
    #   values = <<-EOT
    #     charts:
    #       spectro-rbac:
    #         ${indent(4, local.rbac_yaml)}
    #   EOT
    # }
  }

  cloud_account_id = var.cluster_cloud_account_id

  cloud_config {
    # ssh_key_name = var.cluster_ssh_public_key_name
    region     = var.aws_region
    vpc_id     = var.aws_vpc_id
    az_subnets = var.aws_master_azs_subnets_map
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

  machine_pool {
    name          = "worker-basic"
    count         = var.worker_count
    instance_type = "t3.large"
    az_subnets    = var.aws_worker_azs_subnets_map
    disk_size_gb  = 60
  }

  # fargate_profile {
  #   name    = "fg-1"
  #   subnets = values(var.aws_worker_azs_subnets_map)
  #   additional_tags = {
  #     hello = "test1"
  #   }
  #   selector {
  #     namespace = "fargate"
  #     # labels = {
  #     #   abc = "cool"
  #     # }
  #   }
  # }

  # machine_pool {
  #   control_plane = true
  #   name          = "master-pool"
  #   count         = 3

  #   dynamic "placement" {
  #     for_each = local.placements
  #     content {
  #       cluster           = placement.value.cluster
  #       resource_pool     = placement.value.resource_pool
  #       datastore         = placement.value.datastore
  #       network           = placement.value.network
  #       static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.api.id
  #     }
  #   }
  #   instance_type {
  #     disk_size_gb = var.global_config.api_node.disk_gb
  #     memory_mb    = var.global_config.api_node.memory_mb
  #     cpu          = var.global_config.api_node.cpu
  #   }
  # }

  # dynamic "machine_pool" {
  #   for_each = ["wp-az1", "wp-az2", "wp-az3"]
  #   content {
  #     name = machine_pool.value
  #     count = var.cluster_workers_per_az
  #     placement {
  #       cluster           = local.placements[machine_pool.key].cluster
  #       resource_pool     = local.placements[machine_pool.key].resource_pool
  #       datastore         = local.placements[machine_pool.key].datastore
  #       network           = local.placements[machine_pool.key].network
  #       static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.workers.id
  #     }
  #     instance_type {
  #       disk_size_gb = var.global_config.worker_node.disk_gb
  #       memory_mb    = var.global_config.worker_node.memory_mb
  #       cpu          = var.global_config.worker_node.cpu
  #     }
  #   }
  # }
}
