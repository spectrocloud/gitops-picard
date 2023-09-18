resource "spectrocloud_cluster_profile" "addon_profile" {
  name        = "addon-demo"
  description = "Addon profile for demo"
  #tags        = ["owner:bob"]
  cloud       = "all"
  type        = "add-on"

  pack {
    name   = var.pack_name_argocd
    tag    = var.pack_version_argocd
    uid    = data.spectrocloud_pack.argo-cd.id
    values = file("config/argocd.yaml")
  }
}