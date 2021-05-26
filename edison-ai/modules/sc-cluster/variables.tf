variable "cluster_name" {
  description = "Name of the cluster (e.g: sc-npe1701)"
}
variable "cluster_profile_id" {
  description = "The ID of the Cluster Profile"
}
variable "cluster_cloud_account_id" {
  description = "the cloud account id"
}
variable "cluster_rbac" {
  description = "RBAC mapping"
  type = any
}
variable "aws_region" {
  description = "AWS Region (e.g: us-west-2)"
}
variable "aws_vpc_id" {
  description = "AWS VPC ID"
}
variable "aws_master_azs_subnets_map" {
  description = "AWS Master / Fargate profile - comma-separate public,private subnets"
  type = map(string)
}
variable "aws_worker_azs_subnets_map" {
  description = "worker node subnets - use private subnet"
  type = map(string)
}

# variable "cluster_packs" {
#   type = map(object({
#     tag = string
#     file = string
#   }))
# }

locals {
  n = var.cluster_name

  # Replace all the funky quotes
  rbac_yaml = replace(yamlencode(var.cluster_rbac), "/((?:^|\n)[\\s-]*)\"([\\w-]+)\":/", "$1$2:")

}
