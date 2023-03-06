


provider "kubernetes" {
  host                   = local.cluster_host
  cluster_ca_certificate = base64decode(local.cluster_ca)
  client_certificate     = base64decode(local.cluster_cert)
  client_key             = base64decode(local.cluster_key)
}

resource "kubernetes_secret" "vault_sa" {
  metadata {
    name = "vault-token-955r"
    annotations = {
      "kubernetes.io/service-account.name": "vault"
    }
  }
  type = "kubernetes.io/service-account-token"
}