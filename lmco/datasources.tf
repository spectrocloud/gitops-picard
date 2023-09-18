# Note: These entities should be pre-created in Palette

# The Cloud account to lookup from Palette
data "spectrocloud_cloudaccount_aws" "demo_cloudaccount" {
  name = var.aws_cloudaccount_name
}

# The Infra Cluster profile to lookup from Palette
data "spectrocloud_cluster_profile" "infra_demo" {
  name = var.infra_profile_name
  version = var.infra_profile_version
}

# The addon profile to lookup from Palette
data "spectrocloud_pack" "argo-cd" {
  name = var.pack_name_argocd
  version  = var.pack_version_argocd
  # registry_uid = data.spectrocloud_registry.private-demo.id
}

#data "spectrocloud_registry" "private-demo" {
#  name = "Public Repo"
#}