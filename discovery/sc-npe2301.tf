module "sc-npe-1701" {
  source = "./modules/tke-cluster"

  cluster_name           = "sc-npe-1701"
  cluster_workers_per_az = 1
  cluster_network        = "10.10.242"

  # IP address (reserve 43-44 for 5-node CP)
  cluster_api_start_ip    = "38"
  cluster_api_end_ip      = "42"
  cluster_worker_start_ip = "45"
  cluster_worker_end_ip   = "51"

  netscaler_vip_api      = "10.10.182.4"
  netscaler_vip_nodeport = "10.10.182.5"
  netscaler_vip_ingress  = "10.10.182.5"

  cluster_datastore = "DS001"

  cluster_profile_id = spectrocloud_cluster_profile.sc-npe.id
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
