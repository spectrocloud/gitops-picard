# Locals and cloud accounts defined in cluster_vmware-prod-1.tf

resource "spectrocloud_cluster_vsphere" "prod-vmware-2" {
  name               = "vmware-prod-2"
  cluster_profile_id = spectrocloud_cluster_profile.prodvmware.id
  cloud_account_id   = data.spectrocloud_cloudaccount_vsphere.picard-vc2.id

  cloud_config {
    ssh_key = local.cluster_ssh_public_key

    datacenter = local.datacenter
    folder     = "Demo/spc-prod-vmware-1"

    network_type          = "DDNS"
    network_search_domain = local.cluster_network_search
  }

  # To override or specify values for a cluster:

  # pack {
  #   name   = "spectro-byo-manifest"
  #   tag    = "1.0.x"
  #   values = <<-EOT
  #     manifests:
  #       byo-manifest:
  #         contents: |
  #           # Add manifests here
  #           apiVersion: v1
  #           kind: Namespace
  #           metadata:
  #             labels:
  #               app: wordpress
  #               app2: wordpress2
  #             name: wordpress
  #   EOT
  # }

  machine_pool {
    control_plane           = true
    control_plane_as_worker = true
    name                    = "master-pool"
    count                   = 1

    placement {
      cluster       = "cluster1"
      resource_pool = ""
      datastore     = "datastore55"
      network       = "VM Network"
    }
    instance_type {
      disk_size_gb = 61
      memory_mb    = 4096
      cpu          = 2
    }
  }

  machine_pool {
    name  = "worker-basic"
    count = 2

    placement {
      cluster       = "cluster1"
      resource_pool = ""
      datastore     = "datastore55"
      network       = "VM Network"
    }
    instance_type {
      disk_size_gb = 65
      memory_mb    = 8192
      cpu          = 4
    }
  }
}
