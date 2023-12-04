################################  Vault   ####################################################

# Create the Kubeconfig
resource "vault_generic_secret" "kubeconfig" {
  path      = "${var.global_config.vault_secrets_admin_conf_path}/admin_conf_${local.n}"
  data_json = <<-EOT
    {
      "kubeconfig" : "${replace(spectrocloud_cluster_maas.this.kubeconfig, "\n", "\\n")}"
    }
  EOT
}

# Create the Kubeconfig
resource "vault_generic_secret" "kubeconfig2" {
  path         = "${var.global_config.vault_secrets_admin2_conf_path}/${local.n}"
  disable_read = true
  data_json    = <<-EOT
    {
      "kubeconfig" : "${replace(spectrocloud_cluster_maas.this.kubeconfig, "\n", "\\n")}"
    }
  EOT
}

resource "vault_generic_secret" "etcd_encryption_key" {
  path      = "${var.global_config.vault_secrets_etcd_key_path}/etcd_encryption_key_${local.n}"
  data_json = <<-EOT
    {
      "value" : "${random_id.etcd_encryption_key.b64_std}"
    }
  EOT
}

# Store the etcd client health certificates
resource "vault_generic_secret" "etcd_certs" {
  path         = "${var.global_config.vault_secrets_etcd_certs_path}/etcd-healthcheck-certs_${local.n}"
  disable_read = true
  data_json    = <<-EOT
    {
      "ca-cert" : "${replace(local.etcd-ca-cert, "\n", "\\n")}",
      "healthcheck-client-key": "${replace(local.etcd-healthcheck-client-key, "\n", "\\n")}",
      "healthcheck-client-cert": "${replace(local.etcd-healthcheck-client-cert, "\n", "\\n")}"
    }
  EOT
}
