resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  # path = "demo"
}

resource "vault_kubernetes_auth_backend_role" "example" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "devweb-app"
  bound_service_account_names      = ["internal-app"]
  bound_service_account_namespaces = ["default"]
  token_ttl                        = 86400
  token_policies                   = ["devwebapp"]
}

resource "vault_kubernetes_auth_backend_config" "example" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = local.cluster_host
  kubernetes_ca_cert     = base64decode(local.cluster_ca)
  token_reviewer_jwt     = kubernetes_secret.vault_sa.data.token
  issuer                 = "https://kubernetes.default.svc.cluster.local"
}