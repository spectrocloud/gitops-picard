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

  cluster_profile_id = var.cluster_profile_id

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

  cloud_config {
    #ssh_key    = local.public_key_openssh
    ssh_key    = <<-EOT
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCsKeAiBZJgaChFPLOiAyPG9vebcksGIgYfcZ0Mx/sOp9DElUo4VT91IfwaThwB7ngCiCSQT9voXPHuRAEs2mMrmoqd6+h4CZrFGDA+iGOkM+ErW4NbkKT/VrhTRNMJvDYDLe7oI8NsJYYn+h+zhHksK2yacxqnoVO0LrGOWxOlwqAnMrar8o+LxbmFVk3VzQCXscXZs2Ckqw4y/34XPi9F86fEDtDNQkOxvREyszwIV5QTgxOIvOhTHX0lAUAorqtRniHqRWz59gK74m0Uk1uXWqxuQUBrOx4VYghGQHi/+3dmXxB8sm6fI7Ysr5C97O0bMdNGkDCzeFdk2ib3UUx7SlEWT2BrPwRWcrsKJZgAI0rWq0cnzNnmEZKrlzQcVZdmDOdRwfn/lPS2JFYi7SMY85fgplQB1QM1AGhQJXabEkHh5t6PXJEPhuPqRmQxgR6zXTGjHOOdWjmHJWYATR7fk0xf38oxcEUkxmTsNnN2y1ynYK41+gRukk2vUeNi58gQwA/qsfs2A0hipIN88oXDg4uzA0X6I1RBjcSF6M3NNzujlTfcqA+8C9Ul/WWauqxvmDsvAf5txrOVyEwGW9Xaog/rBoDp26SONCo1KZfxolXecRI8xxUE7hT29TvgfG77ALNvKGmuX6sOasCRfkA7xVXG3bzEEV/jm8P02jWz5Q== spectro@spectro2021
    EOT
    datacenter = var.global_config.datacenter
    folder     = "${var.global_config.vm_folder}/${local.n}"
    static_ip  = true
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
      name  = machine_pool.value
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
