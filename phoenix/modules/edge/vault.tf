
resource "local_file" "kubeconfig" {
  content  = spectrocloud_cluster_edge_native.this.kubeconfig
  filename = "kubeconfig_${local.cluster_id}"
}


# null provider reading a file
resource "null_resource" "write_pem" {

  depends_on = [local_file.kubeconfig]

  triggers = {
    # change this if a force re-run is needed
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "python3 ${path.module}/read_pem_from_oidc.py >> ${path.module}/pem_${local.cluster_id}.pub"

    environment = {
      KUBECONFIG = local_file.kubeconfig.filename
    }
  }
}

data "local_file" "pem_file" {
  depends_on = [null_resource.write_pem]
  filename = "${path.module}/pem_${local.cluster_id}.pub"
}

resource "vault_jwt_auth_backend" "example" {
  type = "jwt"
  jwt_validation_pubkeys = [data.local_file.pem_file.content]
  # path = "demo"
}

resource "vault_jwt_auth_backend_role" "example" {
  backend                          = vault_jwt_auth_backend.example.path
  role_name                        = "devweb-app"
  bound_audiences = "https://kubernetes.default.svc.cluster.local"

  user_claim = "sub"
  role_type       = "jwt"
  policies = " devwebapp"
}

# resource "vault_kubernetes_auth_backend_config" "example" {
#   backend                = vault_jwt_auth_backend.example.path
#   # kubernetes_host        = local.cluster_host
#   # kubernetes_ca_cert     = base64decode(local.cluster_ca)
#   # token_reviewer_jwt     = kubernetes_secret.vault_sa.data.token
#   # issuer                 = "https://kubernetes.default.svc.cluster.local"

# }

