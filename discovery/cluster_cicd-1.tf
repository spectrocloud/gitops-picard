#locals {
#  vmware_static_pool_id_1 = "601229dfc6fdece29d6dc124"
#  vmware_static_pool_id_2 = "601229fa8102177f12cf8dda"
#  vmware_static_pool_id_3 = "60122a31c6fdece2a1fe826a"

#  datacenter = "Datacenter"
#  folder     = "Demo"

#  #cluster_network_search = "spectrocloud.local"

#  cluster_ssh_public_key = <<-EOT
#    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAUaBODDNpQxJJqXz/Q+afauM5EPFp4oDRrWzK/cGd92N+exkd+tEZdO7n3R+WAx0XTcPiVvfKctzekNS6f/ZMrFb5HAPvFJtnGNIE2sm+eryEnAH+Sc7ppZha3/MaSp/A2dm2IobYRvwl04sEi4w1K+I8Rtt+fBe3gV3wnP3E3yOiRx4G2XFC3T6x8MjdOkjO2v6fBluw1M1H2etp1m/n4D70UkeyVJyipcntz0ubHweU7yPNdNS3YkpExYIGhm97C4dyESHEw9PZVdLs1FBL6mW5Yb4qVbg5FkLljLFynh9jL8IAYal0pibAAH+Sk/Nd4865lVJ3lrm8nhBnjs1OEFA487rcxyInxJk/WwLEHvo88Ku9IlYq15Alr8N/JHHackV4kAH0yJNeLtwAysK2gI7Mb5uGnMTPrz73IZqXSxFqnU34Ow+vwu8fXBtXmHA5cUHyz0ARzpgx8A0e8L8SjdY/6dsFhSzGo7JoCElN7sEMo7iI4Wdo8CYdlT+OXizBf3pnM/wxRZclCeRDJpLtd6jl5swv7J5ocINEh1r3BllCyV8L7Xp5gw8IKT3ohz6rliGJwwlq/emqY52eB3wweTLRm30z3h3aQa3YeAR+2JgvWlrJ3YWsYYCLRhSQTfYmpgUkoZIcfB2xkZzp6cyooM0i5Obz313HsxwBHOmNrw== spectro@spectro
#  EOT
#}

# data "spectrocloud_cloudaccount_vsphere" "this" {
#   name = "demo"
# }

locals {
  # ip_cluster-1 = "10.10.137.235"
  issuer_cluster-1 = "dex.cluster1.discovery.spectrocloud.com"
}

locals {
  oidc_cluster-1 = replace(local.oidc_args_string, "%ISSUER_URL%", local.issuer_cluster-1)
  k8s_values_cluster-1 = replace(
    data.spectrocloud_pack.k8s-vsphere.values,
    "/apiServer:\\n\\s+extraArgs:/",
    indent(6, "$0\n${local.oidc_cluster-1}")
  )
}

resource "spectrocloud_cluster_vsphere" "cluster-cicd-1" {
  name               = "vmware-cicd-1"
  cluster_profile_id = spectrocloud_cluster_profile.ifcvmware.id
  #cluster_profile_id = "603e551f39ea6effca77fb07"
  cloud_account_id = data.spectrocloud_cloudaccount_vsphere.this.id

  cloud_config {
    ssh_key = local.cluster_ssh_public_key

    datacenter = local.datacenter
    folder     = "Demo/spc-vmware-cicd-1"

    static_ip = false

    network_type          = "DDNS"
    network_search_domain = local.cluster_network_search
  }

  pack {
    name   = "kubernetes"
    tag    = "1.18.15"
    values = local.k8s_values_cluster-1
  }

  pack {
    name   = "dex"
    tag    = "2.25.0"
    values = templatefile("config/dex_config.yaml", {issuer: local.issuer_cluster-1})
  }

  # Not in T-Mo
  pack {
    name   = "lb-metallb"
    tag    = "0.9.5"
    values = <<-EOT
      manifests:
        metallb:
          namespace: "metallb-system"
          avoidBuggyIps: true
          addresses:
          - 10.10.182.100-10.10.182.109
    EOT
  }

  machine_pool {
    control_plane           = true
    control_plane_as_worker = false
    name                    = "master-pool"
    count                   = 1

    placement {
      cluster       = "cluster1"
      resource_pool = ""
      datastore     = "datastore54"
      network       = "VM Network"
      #static_ip_pool_id = local.vmware_static_pool_id_1
    }
    placement {
      cluster       = "cluster2"
      resource_pool = ""
      datastore     = "datastore55"
      network       = "VM Network"
      #static_ip_pool_id = local.vmware_static_pool_id_1
    }
    placement {
      cluster       = "cluster3"
      resource_pool = ""
      datastore     = "datastore56"
      network       = "VM Network"
      #static_ip_pool_id = local.vmware_static_pool_id_1
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
      cluster       = "cluster1"
      resource_pool = ""
      datastore     = "datastore54"
      network       = "VM Network"
      #static_ip_pool_id = local.vmware_static_pool_id_1
    }
    placement {
      cluster       = "cluster2"
      resource_pool = ""
      datastore     = "datastore55"
      network       = "VM Network"
      #static_ip_pool_id = local.vmware_static_pool_id_2
    }
    placement {
      cluster       = "cluster3"
      resource_pool = ""
      datastore     = "datastore56"
      network       = "VM Network"
      #static_ip_pool_id = local.vmware_static_pool_id_3
    }
    instance_type {
      disk_size_gb = 61
      memory_mb    = 4096
      cpu          = 2
    }
  }
}
