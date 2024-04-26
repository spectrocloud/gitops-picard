
variable "os_name" {
  default = "ubuntu-vsphere"
  description = "The Kubernetes pack version to use for the profile & cluster"
}
variable "os_version_22_04" {
  default = "22.04"
  description = "The OS pack version/tag to use for the profile & cluster"
}
variable "os_version_20_04" {
  default = "20.04"
  description = "The OS pack version/tag to use for the profile & cluster"
}

variable "k8s_name" {
  default = "kubernetes"
  description = "The Kubernetes pack name to use for the profile & cluster"
}
variable "k8s_version" {
  default = "1.24.13"
  description = "The Kubernetes pack version to use for the profile & cluster"
}

variable "cni_name" {
  default = "cni-cilium-oss"
  description = "The CNI pack name to use for the profile & cluster"
}
variable "cni_version" {
  default = "1.12.6"
  description = "The CNI pack version to use for the profile & cluster"
}

variable "csi_name" {
  default = "csi-vsphere-csi"
  description = "The CSI pack name to use for the profile & cluster"
}
variable "csi_version" {
  default = "2.6.x"
  description = "The CSI pack version to use for the profile & cluster"
}

variable "dex_name" {
  default = "dex"
  description = "The Dex pack name to use for the profile & cluster"
}
variable "dex_version" {
  default = "2.35.1"
  description = "The Dex pack version to use for the profile & cluster"
}

variable "vault_name" {
  default = "vault"
  description = "The Vault pack name to use for the profile & cluster"
}
variable "vault_version" {
  default = "0.17.1"
  description = "The Vault pack version to use for the profile & cluster"
}

variable "nginx_name" {
  default = "nginx"
  description = "The NGINX pack name to use for the profile & cluster"
}
variable "nginx_version" {
  default = "1.2.1"
  description = "The NGINX pack version to use for the profile & cluster"
}

variable "tetragon_name" {
  default = "tetragon"
  description = "The Tetragon pack name to use for the profile & cluster"
}
variable "tetragon_version" {
  default = "0.8.3"
  description = "The Tetragon pack version to use for the profile & cluster"
}
