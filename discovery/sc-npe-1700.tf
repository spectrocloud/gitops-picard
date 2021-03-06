module "sc-npe-1700" {
  source = "./modules/tke-cluster"

  cluster_name           = "sc-npe-1700"
  cluster_workers_per_az = 1
  cluster_network        = "10.10.242"

  # IP address (reserve 25-26 for 5-node CP)
  cluster_api_start_ip    = "20"
  cluster_api_end_ip      = "24"
  cluster_worker_start_ip = "27"
  cluster_worker_end_ip   = "37"

  # Commenting below config to skip terraform from creating netscaler resources
  #netscaler_vip_api      = "10.10.182.2"
  #netscaler_vip_nodeport = "10.10.182.3"
  #netscaler_vip_ingress  = "10.10.182.3"

  cluster_datastore = "DS001"

  cluster_profile_id = spectrocloud_cluster_profile.sc-npe-stg.id
  cluster_packs = {
    k8s = {
      tag  = "1.19.7"
      file = "config-stg/k8s.yaml"
    }
    dex = {
      tag  = "2.28.0"
      file = "config-stg/dex.yaml"
    }
  }

  global_config = local.global_config
}
