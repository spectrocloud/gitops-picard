data "spectrocloud_pack" "vault" {
  name    = "vault"
  version = "0.6.0"
}

data "spectrocloud_pack" "prometheus-vsphere" {
  name    = "prometheus-operator"
  version = "9.7.2"
}

data "spectrocloud_pack" "nginx-vsphere" {
  name    = "nginx"
  version = "0.26.1"
}

data "spectrocloud_pack" "hipster-vsphere" {
  name    = "sapp-hipster"
  version = "2.0.0"
}

data "spectrocloud_pack" "lbmetal-vsphere" {
  name    = "lb-metallb"
  version = "0.8.3"
}

data "spectrocloud_pack" "istio-vsphere" {
  name    = "istio"
  version = "1.6.2"
}

data "spectrocloud_pack" "csi-vsphere" {
  name = "csi-vsphere-volume"
  # version  = "1.0.x"
}

data "spectrocloud_pack" "cni-vsphere" {
  name    = "cni-calico"
  version = "3.16.0"
}

data "spectrocloud_pack" "k8s-vsphere" {
  name    = "kubernetes"
  version = "1.18.13"
}

data "spectrocloud_pack" "ubuntu-vsphere" {
  name = "ubuntu-vsphere"
  # version  = "1.0.x"
}

