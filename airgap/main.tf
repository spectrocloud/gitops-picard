terraform {
  backend "s3" {
    bucket                      = "terraform-state"
    key                         = "airgap/terraform.tfstate"
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
    dns_domain       = "10.10.251.30"
    pcg_id           = "61587d5c66127c216e64b496"
    cloud_account_id = data.spectrocloud_cloudaccount_vsphere.default.id

    # Vault
    vault_secrets_path            = "sc/env1/admin_creds"
    vault_secrets_etcd_certs_path = "sc/env1/etcd-certs"
    vault_ssh_keys_path           = "sc/env1/ssh-keys"

    # Network
    network_prefix               = 18
    network_nameserver_addresses = ["10.10.128.8", "8.8.8.8"]
    networks = {
      "10.10.243" = {
        gateway = "10.10.192.1"
        network = "VM Network 2"
      },
      "10.10.244" = {
        gateway = "10.10.192.1"
        network = "VM Network 2"
      }
    }

    # VM properties
    datacenter     = "Datacenter"
    vm_folder      = "boobalan"
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
        datastore     = "DSC_1/Datastore57"
      },
      {
        cluster       = "cluster2"
        resource_pool = ""
        datastore     = "DSC_2/Datastore58"
      },
      {
        cluster       = "cluster3"
        resource_pool = ""
        datastore     = "DSC_3/Datastore59"
      }
    ]
  }
}

data "spectrocloud_cloudaccount_vsphere" "default" {
  name = "us-dc2"
}
