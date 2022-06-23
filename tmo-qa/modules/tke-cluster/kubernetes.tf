##################################  Kubernetes #############################################

locals {
  raw_kubeconfig = yamldecode(spectrocloud_cluster_vsphere.this.kubeconfig)

  cluster_ca   = local.raw_kubeconfig.clusters[0].cluster.certificate-authority-data
  cluster_host = local.raw_kubeconfig.clusters[0].cluster.server
  cluster_cert = local.raw_kubeconfig.users[0].user.client-certificate-data
  cluster_key  = local.raw_kubeconfig.users[0].user.client-key-data
}

provider "kubernetes" {
  host                   = local.cluster_host
  cluster_ca_certificate = base64decode(local.cluster_ca)
  client_certificate     = base64decode(local.cluster_cert)
  client_key             = base64decode(local.cluster_key)
}

data "kubernetes_secret" "etcd-ca" {
  metadata {
    name      = "${local.n}-etcd"
    namespace = "cluster-${spectrocloud_cluster_vsphere.this.id}"
  }
}
