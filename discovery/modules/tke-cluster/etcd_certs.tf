##################################  ETCD Certs   #############################################

provider "kubernetes" {
  config_path = local_file.kubeconfig.filename
}

data "kubernetes_secret" "etcd-ca" {
  metadata {
    name = "${local.n}-etcd"
    namespace = "cluster-${spectrocloud_cluster_vsphere.this.id}"
  }
}

locals {
  etcd-ca-cert = data.kubernetes_secret.etcd-ca.data["tls.crt"]
  etcd-ca-key = data.kubernetes_secret.etcd-ca.data["tls.key"]

  etcd-healthcheck-client-cert = tls_locally_signed_cert.etcd-healthcheck.cert_pem
  etcd-healthcheck-client-key = tls_private_key.etcd-healthcheck.private_key_pem
}

resource "tls_private_key" "etcd-healthcheck" {
  algorithm = "RSA"
}

resource "tls_cert_request" "etcd-healthcheck" {
  key_algorithm   = tls_private_key.etcd-healthcheck.algorithm
  private_key_pem = tls_private_key.etcd-healthcheck.private_key_pem

  subject {
    common_name  = "kube-etcd-healthcheck-client"
    organization = "system:masters"
  }
}

resource "tls_locally_signed_cert" "etcd-healthcheck" {
  cert_request_pem   = tls_cert_request.etcd-healthcheck.cert_request_pem

  ca_key_algorithm   = "RSA"
  ca_cert_pem        = local.etcd-ca-cert
  ca_private_key_pem = local.etcd-ca-key

  // 2 years
  validity_period_hours = 24*365*2

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}
