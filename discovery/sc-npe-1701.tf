module "sc-npe-1701" {
  source = "./modules/tke-cluster"

  cluster_name           = "sc-npe-1701"
  cluster_workers_per_az = 1
  cluster_network        = "10.10.184"

  # IP address (reserve 25-26 for 5-node CP)
  cluster_api_start_ip    = "130"
  cluster_api_end_ip      = "134"
  cluster_worker_start_ip = "135"
  cluster_worker_end_ip   = "144"

  # Commenting below config to skip terraform from creating netscaler resources
  #netscaler_vip_api      = "10.10.182.2"
  #netscaler_vip_nodeport = "10.10.182.3"
  #netscaler_vip_ingress  = "10.10.182.3"

  cluster_datastore = "DS001"

  cluster_profile_id = spectrocloud_cluster_profile.sc-npe.id
  cluster_packs = {
    k8s = {
      tag  = "1.23.9"
      file = "config-stg/k8s.yaml"
    }
    dex = {
      tag  = "2.35.1"
      file = "config-stg/dex.yaml"
    }
    namespace-labeler = {
      tag = "1.0.0"
      file = "config/namespace-labeler.yaml"
    }
  }

  global_config = local.global_config
}
