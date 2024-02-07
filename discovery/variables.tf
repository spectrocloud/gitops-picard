
variable "os_name" {
  default     = "ubuntu-maas"
  description = "The OS pack name to use for the profile & cluster"
}

variable "os_version" {
  default     = "22.04"
  description = "The OS pack version/tag to use for the profile & cluster"
}

variable "k8s_name" {
  default     = "kubernetes"
  description = "The Kubernetes pack name to use for the profile & cluster"
}

variable "k8s_version" {
  default     = "1.26.8"
  description = "The Kubernetes pack version to use for the profile & cluster"
}

variable "cni_name" {
  default     = "cni-cilium-oss"
  description = "The CNI pack name to use for the profile & cluster"
}

variable "cni_version" {
  default     = "1.14.1"
  description = "The CNI pack version to use for the profile & cluster"
}

variable "csi_name" {
  default     = "csi-maas-volume"
  description = "The CSI pack name to use for the profile & cluster"
}

variable "csi_version" {
  default     = "1.0.0"
  description = "The CSI pack version to use for the profile & cluster"
}

variable "dex_name" {
  default     = "dex"
  description = "The Dex pack name to use for the profile & cluster"
}

variable "dex_version" {
  default     = "2.35.1"
  description = "The Dex pack version to use for the profile & cluster"
}

variable "vault_name" {
  default     = "vault"
  description = "The Vault pack name to use for the profile & cluster"
}

variable "vault_version" {
  default     = "0.17.1"
  description = "The Vault pack version to use for the profile & cluster"
}

variable "multus_name" {
  default     = "multus-cni"
  description = "The Multus CNI pack name to use for the profile & cluster"
}

variable "multus_version" {
  default     = "1.4.5"
  description = "The Multus pack version to use for the profile & cluster"
}

variable "whereabouts_name" {
  default     = "whereabouts"
  description = "The whereabouts pack name to use for the profile & cluster"
}

variable "whereabouts_version" {
  default     = "0.9.1"
  description = "The whereabouts pack version to use for the profile & cluster"
}

# Citrix ADC/Netscaler
variable "ns_user" {}
variable "ns_password" {}
variable "ns_endpoint" {}

# Spectro Cloud
variable "sc_host" {}
variable "sc_username" {}
variable "sc_password" {}
variable "sc_project_name" {}

# Vault
variable "vault_address" {}
variable "vault_approle_role_id" {}
variable "vault_approle_secret_id" {}
variable "vault_ldap_role_id" {}
variable "vault_ldap_secret_id" {}
