terraform {
  backend "s3" {
    bucket                      = "discovery-tf"
    key                         = "discovery-airgap/terraform.tfstate"
    region                      = "ignored"
    endpoint                    = "http://10.10.184.50:9199"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
    #access_key, secret_key initialize with backend-config
  }
}

# locals
locals {

  global_config = {
    # Domain
    dns_domain       = "airgap.discovery.spectrocloud.com"
    pcg_id           = "64608c969fa8d770c0fb59ca"
    cloud_account_id = data.spectrocloud_cloudaccount_vsphere.default.id

    # Vault
    vault_secrets_path            = "secret/sc/discovery-airgap/kubeconfig"
    vault_secrets_etcd_certs_path = "secret/sc/discovery-airgap/etcd-certs"
    vault_ssh_keys_path           = "secret/sc/discovery-airgap/ssh-keys"

    # Network
    network_prefix               = 18
    network_nameserver_addresses = ["10.10.128.8"]
    networks = {
      "10.10.244" = {
        gateway = "10.10.192.1"
        network = "VM-NETWORK2"
      }/*,
      "10.10.242" = {
        gateway = "10.10.192.1"
        network = "VM Network 2"
      },
      "10.10.243" = {
        gateway = "10.10.192.1"
        network = "VM Network 2"
      },
      "10.10.244" = {
        gateway = "10.10.192.1"
        network = "VM Network 2"
      },
      "10.10.245" = {
        gateway = "10.10.192.1"
        network = "VM Network 2"
      }*/
    }

    # VM properties
    datacenter     = "Datacenter"
    vm_folder      = "sp-boobalan/discovery/airgap"
    ssh_public_key = "Demo"

    worker_node = {
      cpu       = 4
      memory_mb = 8192
      disk_gb   = 60
    }

    api_node = {
      cpu       = 4
      memory_mb = 8192
      disk_gb   = 60
    }

    # Datastore supports a %DS% template macro
    # which is replaced with var.cluster_datastore
    placements = [
      {
        cluster       = "Cluster1"
        resource_pool = "rp-cluster1-palette-pax"
        datastore     = "vsanDatastore1"
      },
      {
        cluster       = "Cluster2"
        resource_pool = "rp-cluster2-palette-pax"
        datastore     = "vsanDatastore2"
      },
      {
        cluster       = "Cluster3"
        resource_pool = "rp-cluster3-palette-pax"
        datastore     = "vsanDatastore3"
      }
    ]
  }
}

data "spectrocloud_cloudaccount_vsphere" "default" {
  name = "tmpadmin"
}
