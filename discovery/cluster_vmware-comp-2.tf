locals {
  vmware_static_pool_id = "6011e1061d2aa08171553081"
  datacenter            = "Datacenter"
  folder                = "Demo"

  #cluster_network_search = "spectrocloud.local"

  cluster_ssh_public_key = <<-EOT
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAUaBODDNpQxJJqXz/Q+afauM5EPFp4oDRrWzK/cGd92N+exkd+tEZdO7n3R+WAx0XTcPiVvfKctzekNS6f/ZMrFb5HAPvFJtnGNIE2sm+eryEnAH+Sc7ppZha3/MaSp/A2dm2IobYRvwl04sEi4w1K+I8Rtt+fBe3gV3wnP3E3yOiRx4G2XFC3T6x8MjdOkjO2v6fBluw1M1H2etp1m/n4D70UkeyVJyipcntz0ubHweU7yPNdNS3YkpExYIGhm97C4dyESHEw9PZVdLs1FBL6mW5Yb4qVbg5FkLljLFynh9jL8IAYal0pibAAH+Sk/Nd4865lVJ3lrm8nhBnjs1OEFA487rcxyInxJk/WwLEHvo88Ku9IlYq15Alr8N/JHHackV4kAH0yJNeLtwAysK2gI7Mb5uGnMTPrz73IZqXSxFqnU34Ow+vwu8fXBtXmHA5cUHyz0ARzpgx8A0e8L8SjdY/6dsFhSzGo7JoCElN7sEMo7iI4Wdo8CYdlT+OXizBf3pnM/wxRZclCeRDJpLtd6jl5swv7J5ocINEh1r3BllCyV8L7Xp5gw8IKT3ohz6rliGJwwlq/emqY52eB3wweTLRm30z3h3aQa3YeAR+2JgvWlrJ3YWsYYCLRhSQTfYmpgUkoZIcfB2xkZzp6cyooM0i5Obz313HsxwBHOmNrw== spectro@spectro
  EOT
}

data "spectrocloud_cloudaccount_vsphere" "this" {
  name = "demo"
}

#resource "spectrocloud_cluster_vsphere" "comp-2" {
#  name               = "vmware-discovery-1"
#  cluster_profile_id = spectrocloud_cluster_profile.devvmware.id
#  cloud_account_id   = data.spectrocloud_cloudaccount_vsphere.this.id

#  cloud_config {
#    ssh_key = local.cluster_ssh_public_key

#    datacenter = local.datacenter
#    folder     = "Demo/spc-vmware-discovery-1"

#    static_ip = true

#    #network_type          = "VIP"
#    #network_search_domain = local.cluster_network_search
#  }

#  # To override or specify values for a cluster:

#  #pack {
#  #  name   = "lb-metallb"
#  #  tag    = "0.8.x"
#  #  values = <<-EOT
#  #    manifests:
#  #      metallb:

#  #        #The namespace to use for deploying MetalLB
#  #        namespace: "metallb-system"

#  #        #MetalLB will skip setting .0 & .255 IP address when this flag is enabled
#  #        avoidBuggyIps: true

#  #        # Layer 2 config; The IP address range MetalLB should use while assigning IP's for svc type LoadBalancer
#  #        # For the supported formats, check https://metallb.universe.tf/configuration/#layer-2-configuration
#  #        addresses:
#  #        - 10.10.182.100-10.10.182.109
#  #  EOT
#  #}


#  machine_pool {
#    control_plane           = true
#    control_plane_as_worker = true
#    name                    = "master-pool"
#    count                   = 3

#    placement {
#      cluster           = "cluster1"
#      resource_pool     = ""
#      datastore         = "datastore54"
#      network           = "VM Network 2"
#      static_ip_pool_id = local.vmware_static_pool_id
#    }
#    placement {
#      cluster           = "cluster2"
#      resource_pool     = ""
#      datastore         = "datastore55"
#      network           = "VM Network 2"
#      static_ip_pool_id = local.vmware_static_pool_id
#    }
#    placement {
#      cluster           = "cluster3"
#      resource_pool     = ""
#      datastore         = "datastore56"
#      network           = "VM Network 2"
#      static_ip_pool_id = local.vmware_static_pool_id
#    }
#    instance_type {
#      disk_size_gb = 61
#      memory_mb    = 4096
#      cpu          = 2
#    }
#  }

#  machine_pool {
#    name  = "worker-pool"
#    count = 3

#    placement {
#      cluster           = "cluster1"
#      resource_pool     = ""
#      datastore         = "datastore54"
#      network           = "VM Network 2"
#      static_ip_pool_id = local.vmware_static_pool_id
#    }
#    placement {
#      cluster           = "cluster2"
#      resource_pool     = ""
#      datastore         = "datastore55"
#      network           = "VM Network 2"
#      static_ip_pool_id = local.vmware_static_pool_id
#    }
#    placement {
#      cluster           = "cluster3"
#      resource_pool     = ""
#      datastore         = "datastore56"
#      network           = "VM Network 2"
#      static_ip_pool_id = local.vmware_static_pool_id
#    }
#    instance_type {
#      disk_size_gb = 62
#      memory_mb    = 4096
#      cpu          = 2
#    }
#  }
#}

resource "spectrocloud_cluster_vsphere" "comp-3" {
  name               = "vmware-discovery-2"
  cluster_profile_id = spectrocloud_cluster_profile.devvmware.id
  cloud_account_id   = data.spectrocloud_cloudaccount_vsphere.this.id

  cloud_config {
    ssh_key = local.cluster_ssh_public_key

    datacenter = local.datacenter
    folder     = "Demo/spc-vmware-discovery-1"

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
      static_ip_pool_id = local.vmware_static_pool_id
    }
    placement {
      cluster           = "cluster22"
      resource_pool     = ""
      datastore         = "datastore55"
      network           = "VM Network 2"
      static_ip_pool_id = local.vmware_static_pool_id
    }
    placement {
      cluster           = "cluster33"
      resource_pool     = ""
      datastore         = "datastore56"
      network           = "VM Network 2"
      static_ip_pool_id = local.vmware_static_pool_id
    }
    instance_type {
      disk_size_gb = 61
      memory_mb    = 4096
      cpu          = 2
    }
  }

}
