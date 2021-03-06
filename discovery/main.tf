terraform {
  backend "s3" {
    bucket                      = "terraform-state"
    key                         = "discovery/terraform.tfstate"
    region                      = "ignored"
    endpoint                    = "https://10.10.137.64:9000"
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
    pcg_id           = "603e528439ea6effbcd224d8"
    cloud_account_id = data.spectrocloud_cloudaccount_vsphere.default.id

    # Vault
    vault_secrets_path            = "sc/env1/admin_creds"
    vault_secrets_etcd_certs_path = "sc/env1/etcd-certs"
    vault_ssh_keys_path           = "sc/env1/ssh-keys"

    # Network
    network_prefix               = 18
    network_nameserver_addresses = ["10.10.128.8", "8.8.8.8"]
    networks = {
      "10.10.242" = {
        gateway = "10.10.192.1"
        network = "VM Network 2"
      },
      "10.10.243" = {
        gateway = "10.10.192.1"
        network = "VM Network 2"
      }
    }

    # VM properties
    datacenter     = "Datacenter"
    vm_folder      = "Demo"
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
        cluster       = "cluster1"
        resource_pool = ""
        datastore     = "datastore54"
      },
      {
        cluster       = "cluster2"
        resource_pool = ""
        datastore     = "datastore55"
      },
      {
        cluster       = "cluster3"
        resource_pool = ""
        datastore     = "datastore56"
      }
    ]
  }
}

data "spectrocloud_cloudaccount_vsphere" "default" {
  name = "npe"
}
