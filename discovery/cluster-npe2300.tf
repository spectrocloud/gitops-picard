module "px-npe2300" {
  source = "./modules/tke-cluster"

  cluster_name           = "px-npe2300"
  cluster_workers_per_az = 1
  cluster_network        = "10.10.242"

  # IP address (reserve 25-26 for 5-node CP)
  cluster_api_start_ip    = "20"
  cluster_api_end_ip      = "24"
  cluster_worker_start_ip = "27"
  cluster_worker_end_ip   = "37"

  netscaler_vip_api      = "10.10.182.2"
  netscaler_vip_nodeport = "10.10.182.3"
  netscaler_vip_ingress  = "10.10.182.4"

  cluster_datastore = "DS001"

  cluster_profile_id = spectrocloud_cluster_profile.px-npe2003-stg.id
  cluster_packs = {
    k8s = {
      tag  = "1.19.7"
      file = "config/k8s-stg.yaml"
    }
    dex = {
      tag  = "2.28.0"
      file = "config/dex-stg.yaml"
    }
  }

  global_config = local.global_config
}
