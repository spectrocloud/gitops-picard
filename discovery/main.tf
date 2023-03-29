terraform {
  backend "s3" {
    bucket                      = "discovery-tf"
    key                         = "discovery/terraform.tfstate"
    region                      = "ignored"
    endpoint                    = "http://10.10.184.99:9199"
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
    dns_domain       = "discovery.spectrocloud.com"
    pcg_id           = "63912b951a1c6214cead9ce0"
    cloud_account_id = data.spectrocloud_cloudaccount_vsphere.default.id

    # Vault
    vault_secrets_path            = "secret/sc/discovery/kubeconfig"
    vault_secrets_etcd_certs_path = "secret/sc/discovery/etcd-certs"
    vault_ssh_keys_path           = "secret/sc/discovery/ssh-keys"

    # Network
    network_prefix               = 18
    network_nameserver_addresses = ["10.10.128.8"]
    networks = {
      "10.10.184" = {
        gateway = "10.10.128.1"
        network = "VM Network"
      },
      "10.10.183" = {
        gateway = "10.10.128.1"
        network = "VM Network"
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
    vm_folder      = "SC_TMO"
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
        resource_pool = ""
        datastore     = "vsanDatastore"
      },
      {
        cluster       = "Cluster2"
        resource_pool = ""
        datastore     = "vsanDatastore2"
      },
      {
        cluster       = "Cluster3"
        resource_pool = ""
        datastore     = "vsanDatastore3"
      }
    ]
  }
}

data "spectrocloud_cloudaccount_vsphere" "default" {
  name = "vsphere-admin"
}
