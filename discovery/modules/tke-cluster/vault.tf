################################  Vault   ####################################################

# Create the Kubeconfig
resource "vault_generic_secret" "kubeconfig" {
  path      = "${var.global_config.vault_secrets_path}/admin_conf_${local.n}"
  data_json = <<-EOT
    {
      "kubeconfig" : "${replace(spectrocloud_cluster_vsphere.this.kubeconfig, "\n", "\\n")}"
    }
  EOT
}

resource "vault_generic_secret" "etcd_encryption_key" {
  path      = "${var.global_config.vault_secrets_path}/etcd_encryption_key_${local.n}"
  data_json = <<-EOT
    {
      "value" : "${random_id.etcd_encryption_key.b64_std}"
    }
  EOT
}

# resource "vault_generic_secret" "etcd_encryption_key" {
#   path      = "${var.global_config.vault_secrets_path}/admin_conf_${local.n}"
#   data_json = <<-EOT
#     {
#       "value" : random_id.etcd_encryption_key.b64_std
#     }
#   EOT
# }
