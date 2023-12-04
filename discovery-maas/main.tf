terraform {
  backend "s3" {
    bucket                      = "tke-prd-spectrocloud-tf-automation"
    key                         = "prd6001/terraform.tfstate"
    region                      = "us-west-2"
    endpoint                    = "https://pxeit-fb02.pe.t-mobile.com"
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
    dns_domain       = "tke.t-mobile.com"

    maas_domain = "maas"

    # Use the PCG or System cloud gateway id 
    pcg_id           = "6463c66d6c0a8685c1390718"

    cloud_account_id = data.spectrocloud_cloudaccount_maas.default.id

    # Vault
    vault_secrets_admin_conf_path  = "pe/secret/tke/admin_creds"
    vault_secrets_admin2_conf_path = "pe/ci/tke/central/shared/admin_conf"
    vault_secrets_etcd_key_path    = "pe/secret/tke/admin_creds"
    vault_secrets_etcd_certs_path  = "pe/ci/tke/central/main/deploy-tke-monitoring"
    vault_ssh_keys_path            = "pe/secret/tke/admin_creds"

    # VM properties
    datacenter     = "Polaris_CaaS_NPE02"
    vm_folder      = "px-snd2001_vms"
    ssh_public_key = "Demo"

    worker_node = {
      cpu       = 16
      memory_mb = 131072
      disk_gb   = 200
    }

    api_node = {
      cpu       = 8
      memory_mb = 131072
      disk_gb   = 60
    }

  }
}

# Look up a MaaS cloudaccount configured in Palette
data "spectrocloud_cloudaccount_maas" "default" {
  name = "tke-maas-4001"
}
