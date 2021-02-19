# Locals and cloud accounts defined in cluster_vmware-prod-1.tf

resource "spectrocloud_cluster_vsphere" "prod-vmware-2" {
  name               = "vmware-prod-2"
  cluster_profile_id = spectrocloud_cluster_profile.prodvmware.id
  cloud_account_id   = data.spectrocloud_cloudaccount_vsphere.picard-vc2.id

  cloud_config {
    ssh_key = local.cluster_ssh_public_key

    datacenter = local.datacenter
    folder     = "Demo/spc-prod-vmware-2"

    network_type          = "DDNS"
    network_search_domain = local.cluster_network_search
  }

  # To override or specify values for a cluster:

  pack {
    name   = "lb-metallb"
    tag    = "0.8.x"
    values = <<-EOT
      manifests:
        metallb:

          #The namespace to use for deploying MetalLB
          namespace: "metallb-system"

          #MetalLB will skip setting .0 & .255 IP address when this flag is enabled
          avoidBuggyIps: true

          # Layer 2 config; The IP address range MetalLB should use while assigning IP's for svc type LoadBalancer
          # For the supported formats, check https://metallb.universe.tf/configuration/#layer-2-configuration
          addresses:
          - 10.10.182.20-10.10.182.29
    EOT
  }

  machine_pool {
    control_plane           = true
    control_plane_as_worker = true
    name                    = "master-pool"
    count                   = 1

    placement {
      cluster       = "cluster3"
      resource_pool = ""
      datastore     = "datastore56"
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
    count = 3

    placement {
      cluster       = "cluster3"
      resource_pool = ""
      datastore     = "datastore56"
      network       = "VM Network"
    }
    instance_type {
      disk_size_gb = 65
      memory_mb    = 8192
      cpu          = 4
    }
  }
}
