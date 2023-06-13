module "tool-dev-2" {
  source = "./modules/sc-cluster"

  cluster_name = "tool-dev-2"
  # cluster_rbac = local.rbac_map["tool-dev-2"]

  cluster_profile_id       = data.spectrocloud_cluster_profile.sc.id
  cluster_cloud_account_id = data.spectrocloud_cloudaccount_aws.default.id

  worker_count = 3

  aws_region = "us-east-1"
  aws_vpc_id = "vpc-0c9679602584608f9"

  aws_master_azs_subnets_map = {
    "us-east-1a" = "subnet-07f0af093b8233990,subnet-080b9dc42d15b57a2"
    "us-east-1b" = "subnet-0e0d96dc7ad3f02a5,subnet-025428faaddc4201f"
    "us-east-1c" = "subnet-09e74165071ce03e6,subnet-0964e92baa663e495"
  }
  aws_worker_azs_subnets_map = {
    "us-east-1a" = "subnet-07f0af093b8233990"
    "us-east-1b" = "subnet-0e0d96dc7ad3f02a5"
    "us-east-1c" = "subnet-09e74165071ce03e6"
  }

  # cluster_packs = {
  #   k8s = {
  #     tag  = "1.19.7"
  #     file = "config-stg/k8s.yaml"
  #   }
  #   dex = {
  #     tag  = "2.28.0"
  #     file = "config-stg/dex.yaml"
  #   }
  # }

  # global_config = local.global_config
}
