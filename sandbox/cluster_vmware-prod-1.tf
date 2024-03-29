data "spectrocloud_cloudaccount_vsphere" "picard-vc2" {
  name = "picard-vc2-2"
}

# resource "spectrocloud_cluster_rbac" "prod-vmware-1" {
#   type = "rolebinding"
#   namespace = "foo"
#   roleName = "admin"
#   roleKind = "ClusterRole"
# }
# resource "spectrocloud_cluster_rbac" "prod-vmware-1" {
#   type = "rolebinding"
#   type = "clusterrolebinding"
#   namespace = "foo"
#   roleName = "admin"
#   roleKind = "ClusterRole"
#   mapToAllClusters = true
#   labels = {
#     cicd = dev
#   }
# }

resource "spectrocloud_cluster_vsphere" "prod-vmware-1" {

  name = "vmware-prod-1"

  cluster_profile {
    id = spectrocloud_cluster_profile.prodvmware.id

    # To override or specify values for a cluster:
    pack {
      name   = "lb-metallb"
      tag    = "0.11.0"
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
            - 10.10.182.10-10.10.182.19
      EOT
    }
  }

  cloud_account_id = data.spectrocloud_cloudaccount_vsphere.picard-vc2.id

  # rbac = [
  #   spectroclu_cluster_rbac.sdfs.id
  # ]

  cloud_config {
    ssh_key = local.cluster_ssh_public_key

    datacenter = local.datacenter
    folder     = "Demo/spc-prod-vmware-1"

    network_type          = "DDNS"
    network_search_domain = local.cluster_network_search
  }


  machine_pool {
    control_plane           = true
    control_plane_as_worker = true
    name                    = "master-pool"
    count                   = 3

    placement {
      cluster       = "Cluster2"
      resource_pool = ""
      datastore     = "Datastore58"
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
    count = 1

    placement {
      cluster       = "Cluster2"
      resource_pool = ""
      datastore     = "Datastore58"
      network       = "VM Network"
    }
    instance_type {
      disk_size_gb = 65
      memory_mb    = 8192
      cpu          = 4
    }
  }

  machine_pool {
    name  = "gpu-basic"
    count = 1

    placement {
      cluster       = "Cluster2"
      resource_pool = ""
      datastore     = "Datastore58"
      network       = "VM Network"
    }
    instance_type {
      disk_size_gb = 65
      memory_mb    = 8192
      cpu          = 4
    }
  }


}

# hello, hello, hello
