module "tt-prd6102" {
  source = "./modules/tke-cluster"

  cluster_name           = "tt-prd6102"
  cluster_workers_per_az = 4

  maas_resource_pool      = "TKE2_WP"

  netscaler_vip_api      = "10.139.142.27"
  netscaler_vip_nodeport = "10.139.142.36"
  netscaler_vip_ingress  = "10.139.142.36"

  cluster_profile_id  = spectrocloud_cluster_profile.tt-prd6001-cilium.id

  cluster_packs = {
    k8s = {
      tag  = var.k8s_version
      file = "config/k8s.yaml"
    }
    dex = {
      tag  = var.dex_version
      file = "config/dex.yaml"
    }
    namespace-labeler = {
      tag  = "1.0.0"
      file = "config/namespace-labeler.yaml"
    }
    cred-provider = {
      tag  = "1.0.0"
      file = "config/cred-provider.yaml"
    }
  }
  global_config = local.global_config
}
