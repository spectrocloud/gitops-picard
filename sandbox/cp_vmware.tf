# If looking up a cluster profile instead of creating a new one
# data "spectrocloud_cluster_profile" "profile" {
#   # id = <uid>
#   name = var.cluster_cluster_profile_name
# }


data "spectrocloud_pack" "nginx-vsphere" {
  name    = "nginx"
  version = "1.0.4"
  registry_uid = data.spectrocloud_registry.registry.id
}

data "spectrocloud_pack" "hipster-vsphere" {
  name    = "sapp-hipster"
  version = "2.0.0"
  registry_uid = data.spectrocloud_registry.registry.id
}

data "spectrocloud_pack" "lbmetal-vsphere" {
  name    = "lb-metallb"
  version = "0.11.0"
  registry_uid = data.spectrocloud_registry.registry.id
}

data "spectrocloud_pack" "istio-vsphere" {
  name    = "istio"
  version = "1.6.2"
  registry_uid = data.spectrocloud_registry.registry.id
}

data "spectrocloud_pack" "csi-vsphere" {
  name    = "csi-vsphere-csi"
  version = "2.3.0"
  registry_uid = data.spectrocloud_registry.registry.id
}

data "spectrocloud_pack" "cni-vsphere" {
  name    = "cni-calico"
  version = "3.19.0"
  registry_uid = data.spectrocloud_registry.registry.id
}

data "spectrocloud_pack" "k8s-vsphere" {
  name    = "kubernetes"
  version = "1.20.14"
  registry_uid = data.spectrocloud_registry.registry.id
}

data "spectrocloud_pack" "ubuntu-vsphere" {
  name    = "ubuntu-vsphere"
  version = "18.04"
  registry_uid = data.spectrocloud_registry.registry.id
}

locals {
  # vsphere_k8s_values = replace(
  #   data.spectrocloud_pack.k8s-vsphere.values,
  #   "/apiServer:\\n\\s+extraArgs:/",
  #   indent(6, "$0\n${local.oidc_args_string}")
  # )

  # vsphere_k8s_values = data.spectrocloud_pack.k8s-vsphere.values
}

resource "spectrocloud_cluster_profile" "prodvmware" {
  name        = "ProdVMware"
  description = "basic cp"
  cloud       = "vsphere"
  type        = "cluster"

  pack {
    name   = data.spectrocloud_pack.ubuntu-vsphere.name
    tag    = data.spectrocloud_pack.ubuntu-vsphere.version
    uid    = data.spectrocloud_pack.ubuntu-vsphere.id
    values = data.spectrocloud_pack.ubuntu-vsphere.values
  }

  pack {
    name   = data.spectrocloud_pack.k8s-vsphere.name
    tag    = data.spectrocloud_pack.k8s-vsphere.version
    uid    = data.spectrocloud_pack.k8s-vsphere.id
    values = file("config/k8s-oidc.yaml")
  }

  pack {
    name   = data.spectrocloud_pack.cni-vsphere.name
    tag    = data.spectrocloud_pack.cni-vsphere.version
    uid    = data.spectrocloud_pack.cni-vsphere.id
    values = data.spectrocloud_pack.cni-vsphere.values
  }

  pack {
    name   = data.spectrocloud_pack.csi-vsphere.name
    tag    = data.spectrocloud_pack.csi-vsphere.version
    uid    = data.spectrocloud_pack.csi-vsphere.id
    values = data.spectrocloud_pack.csi-vsphere.values
  }

  pack {
    name   = data.spectrocloud_pack.lbmetal-vsphere.name
    tag    = data.spectrocloud_pack.lbmetal-vsphere.version
    uid    = data.spectrocloud_pack.lbmetal-vsphere.id
    values = <<-EOT
      pack:
        spectrocloud.com/install-priority: "0"
      manifests:
        metallb:
          #The namespace to use for deploying MetalLB
          namespace: "metallb-system"

          #MetalLB will skip setting .0 & .255 IP address when this flag is enabled
          avoidBuggyIps: true

          # Layer 2 config; The IP address range MetalLB should use while assigning IP's for svc type LoadBalancer
          # For the supported formats, check https://metallb.universe.tf/configuration/#layer-2-configuration
          addresses:
            - 10.10.182.0-10.10.182.9
    EOT
  }

  pack {
    name   = "istio"
    tag    = "1.6.x"
    uid    = data.spectrocloud_pack.istio-vsphere.id
    values = <<-EOT
      charts:
        istio-operator:
          hub: docker.io/istio
          tag: 1.6.2
          operatorNamespace: istio-operator
          istioNamespace: istio-system
        istio-controlplane:
          namespace: istio-system
          controlPlaneName: istio-controlplane
          ############################################ ISTIO PROFILES #################################################
          # default: generally for production (istiod, prometheus, ingress gateway)
          # demo: enable everything for production (istiod, prometheus, ingress gateway, egress, kiali, tracing)
          # remote: remote cluster of a multicluster mesh, with a shared control plane
          ############################################################################################################
          spec:
            profile: demo
            # Disable Pod disruption budget for the additional components. Otherwise, pods will get stuck when node is drained
            values:
              kiali:
                service:
                  type: LoadBalancer
              global:
                defaultPodDisruptionBudget:
                  enabled: false
    EOT
  }

  pack {
    name   = data.spectrocloud_pack.nginx-vsphere.name
    tag    = data.spectrocloud_pack.nginx-vsphere.version
    uid    = data.spectrocloud_pack.nginx-vsphere.id
    values = data.spectrocloud_pack.nginx-vsphere.values
  }

  pack {
    name   = data.spectrocloud_pack.hipster-vsphere.name
    tag    = data.spectrocloud_pack.hipster-vsphere.version
    uid    = data.spectrocloud_pack.hipster-vsphere.id
    values = data.spectrocloud_pack.hipster-vsphere.values
  }

}
