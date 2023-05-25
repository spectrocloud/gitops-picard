################################  Vault   ####################################################

# Create the Kubeconfig
resource "vault_generic_secret" "kubeconfig" {
  path      = "${var.global_config.vault_secrets_path}/${local.n}"
  data_json = <<-EOT
    {
      "kubeconfig" : "${replace(spectrocloud_cluster_vsphere.this.kubeconfig, "\n", "\\n")}"
    }
  EOT
}

# Store the etcd_encryption_key
resource "vault_generic_secret" "etcd_encryption_key" {
  path      = "${var.global_config.vault_secrets_etcd_certs_path}/${local.n}_encryption_key"
  data_json = <<-EOT
    {
      "value" : "${random_id.etcd_encryption_key.b64_std}"
    }
  EOT
}

# Store the etcd client health certificates
resource "vault_generic_secret" "etcd_certs" {
  path         = "${var.global_config.vault_secrets_etcd_certs_path}/${local.n}_certs"
  disable_read = true
  data_json    = <<-EOT
    {
      "ca-cert" : "${replace(local.etcd-ca-cert, "\n", "\\n")}",
      "healthcheck-client-key": "${replace(local.etcd-healthcheck-client-key, "\n", "\\n")}",
      "healthcheck-client-cert": "${replace(local.etcd-healthcheck-client-cert, "\n", "\\n")}"
    }
  EOT
}

# Store the SSH keys in Vault
resource "vault_generic_secret" "ssh_keys" {
  path         = "${var.global_config.vault_ssh_keys_path}/${local.n}"
  disable_read = true
  data_json    = <<-EOT
      {
      "private" : "${replace(local.private_key_pem, "\n", "\\n")}",
      "public" : "${replace(local.public_key_openssh, "\n", "\\n")}"
    }
  EOT
}