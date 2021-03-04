
resource "spectrocloud_privatecloudgateway_ippool" "cluster-1" {
  private_cloud_gateway_id   = "603e528439ea6effbcd224d8"
  name                       = "cluster-1"
  network_type               = "range"
  ip_start_range             = "10.10.242.20"
  ip_end_range               = "10.10.242.34"
  prefix                     = 18
  gateway                    = "10.10.192.1"
  nameserver_addresses       = ["10.10.128.8", "8.8.8.8"]
  restrict_to_single_cluster = false
  #nameserver_search_suffix = ["test.com"]
}

resource "spectrocloud_cluster_vsphere" "cluster-1" {
  name               = "vmware-cluster-1"
  cluster_profile_id = spectrocloud_cluster_profile.ifcvmware.id
  cloud_account_id   = data.spectrocloud_cloudaccount_vsphere.this.id

  cloud_config {
    ssh_key = local.cluster_ssh_public_key

    datacenter = local.datacenter
    folder     = "Demo/spc-vmware-cluster-1"

    static_ip = true

    #network_type          = "VIP"
    #network_search_domain = local.cluster_network_search
  }

  # To override or specify values for a cluster:

  #pack {
  #  name   = "lb-metallb"
  #  tag    = "0.8.x"
  #  values = <<-EOT
  #    manifests:
  #      metallb:

  #        #The namespace to use for deploying MetalLB
  #        namespace: "metallb-system"

  #        #MetalLB will skip setting .0 & .255 IP address when this flag is enabled
  #        avoidBuggyIps: true

  #        # Layer 2 config; The IP address range MetalLB should use while assigning IP's for svc type LoadBalancer
  #        # For the supported formats, check https://metallb.universe.tf/configuration/#layer-2-configuration
  #        addresses:
  #        - 10.10.182.100-10.10.182.109
  #  EOT
  #}


  machine_pool {
    control_plane           = true
    control_plane_as_worker = true
    name                    = "master-pool"
    count                   = 3

    placement {
      cluster           = "cluster1"
      resource_pool     = ""
      datastore         = "datastore54"
      network           = "VM Network 2"
      static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.cluster-1.id
    }
    placement {
      cluster           = "cluster2"
      resource_pool     = ""
      datastore         = "datastore55"
      network           = "VM Network 2"
      static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.cluster-1.id
    }
    placement {
      cluster           = "cluster3"
      resource_pool     = ""
      datastore         = "datastore56"
      network           = "VM Network 2"
      static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.cluster-1.id
    }
    instance_type {
      disk_size_gb = 61
      memory_mb    = 4096
      cpu          = 2
    }
  }

  machine_pool {
    name  = "worker-pool"
    count = 3
    placement {
      cluster           = "cluster1"
      resource_pool     = ""
      datastore         = "datastore54"
      network           = "VM Network 2"
      static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.cluster-1.id
    }
    placement {
      cluster           = "cluster2"
      resource_pool     = ""
      datastore         = "datastore55"
      network           = "VM Network 2"
      static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.cluster-1.id
    }
    placement {
      cluster           = "cluster3"
      resource_pool     = ""
      datastore         = "datastore56"
      network           = "VM Network 2"
      static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.cluster-1.id
    }
    instance_type {
      disk_size_gb = 61
      memory_mb    = 4096
      cpu          = 2
    }
  }
}
