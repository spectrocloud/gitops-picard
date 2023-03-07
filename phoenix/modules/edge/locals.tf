locals {
  raw_kubeconfig = yamldecode(spectrocloud_cluster_edge_native.this.kubeconfig)

  cluster_ca   = local.raw_kubeconfig.clusters[0].cluster.certificate-authority-data
  cluster_host = local.raw_kubeconfig.clusters[0].cluster.server
  cluster_cert = local.raw_kubeconfig.users[0].user.client-certificate-data
  cluster_key  = local.raw_kubeconfig.users[0].user.client-key-data
}
