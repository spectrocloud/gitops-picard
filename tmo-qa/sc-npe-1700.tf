module "sc-npe-1700" {
  source = "./modules/tke-cluster"

  cluster_name           = "ar-teams-1700"
  cluster_workers_per_az = 1
  cluster_network        = "10.10.188"

  # IP address (reserve 25-26 for 5-node CP)
  cluster_api_start_ip    = "40"
  cluster_api_end_ip      = "44"
  cluster_worker_start_ip = "45"
  cluster_worker_end_ip   = "55"

  # Commenting below config to skip terraform from creating netscaler resources
  netscaler_vip_api      = "10.10.188.20"
  netscaler_vip_nodeport = "10.10.188.21"
  netscaler_vip_ingress  = "10.10.188.22"

  cluster_datastore = "DS001"

  cluster_profile_id = spectrocloud_cluster_profile.sc-npe-stg.id
  cluster_packs = {
    k8s = {
      tag  = "1.21.6"
      file = "config-stg/k8s.yaml"
    }
    dex = {
      tag  = "2.28.0"
      file = "config-stg/dex.yaml"
    }
    namespace-labeler = {
      tag = "1.0.0"
      file = "config/namespace-labeler.yaml"
    }
  }

  global_config = local.global_config
}
