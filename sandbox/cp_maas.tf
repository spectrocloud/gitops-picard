# If looking up a cluster profile instead of creating a new one
# data "spectrocloud_cluster_profile" "profile" {
#   # id = <uid>
#   name = var.cluster_cluster_profile_name
# }


# data "spectrocloud_pack" "nginx-maas" {
#   name    = "nginx"
#   version = "0.43.0"
# }

# data "spectrocloud_pack" "hipster-maas" {
#   name    = "sapp-hipster"
#   version = "2.0.0"
# }

# data "spectrocloud_pack" "lbmetal-maas" {
#   name    = "lb-metallb"
#   version = "0.8.3"
# }

# data "spectrocloud_pack" "istio-maas" {
#   name    = "istio"
#   version = "1.6.2"
# }

data "spectrocloud_pack" "csi-maas" {
  name = "csi-maas-volume"
  # version  = "1.0.x"
}

data "spectrocloud_pack" "cni-maas" {
  name    = "cni-calico"
  version = "3.16.0"
}

data "spectrocloud_pack" "k8s-maas" {
  name    = "kubernetes"
  version = "1.18.15"
}

data "spectrocloud_pack" "ubuntu-maas" {
  name = "ubuntu-maas"
  # version  = "1.0.x"
}

resource "spectrocloud_cluster_profile" "prodmaas" {
  name        = "Prodmaas"
  description = "basic cp"
  cloud       = "maas"
  type        = "cluster"

  #pack {
  #  name   = "lb-metallb"
  #  tag    = "0.8.x"
  #  uid    = data.spectrocloud_pack.lbmetal-maas.id
  #  values = <<-EOT
  #    manifests:
  #      metallb:

  #        #The namespace to use for deploying MetalLB
  #        namespace: "metallb-system"

  #        #MetalLB will skip setting .0 & .255 IP address when this flag is enabled
  #        avoidBuggyIps: true

  #        # Layer 2 config; The IP address range MetalLB should use while assigning IP's for svc type LoadBalancer
  #        # For the supported formats, check https://metallb.universe.tf/configuration/#layer-2-configuration
  #        addresses:
  #        - 10.10.182.0-10.10.182.9
  #  EOT
  #}

  #pack {
  #  name   = "nginx"
  #  tag    = "0.43.0"
  #  uid    = data.spectrocloud_pack.nginx-maas.id
  #  values = data.spectrocloud_pack.nginx-maas.values
  #}

  #pack {
  #  name   = "sapp-hipster"
  #  tag    = "2.0.x"
  #  uid    = data.spectrocloud_pack.hipster-maas.id
  #  values = data.spectrocloud_pack.hipster-maas.values
  #}

  #pack {
  #  name   = "istio"
  #  tag    = "1.6.x"
  #  uid    = data.spectrocloud_pack.istio-maas.id
  #  values = <<-EOT
  #    charts:
  #      istio-operator:
  #        hub: docker.io/istio
  #        tag: 1.6.2
  #        operatorNamespace: istio-operator
  #        istioNamespace: istio-system
  #      istio-controlplane:
  #        namespace: istio-system
  #        controlPlaneName: istio-controlplane
  #        ############################################ ISTIO PROFILES #################################################
  #        # default: generally for production (istiod, prometheus, ingress gateway)
  #        # demo: enable everything for production (istiod, prometheus, ingress gateway, egress, kiali, tracing)
  #        # remote: remote cluster of a multicluster mesh, with a shared control plane
  #        ############################################################################################################
  #        spec:
  #          profile: demo
  #          # Disable Pod disruption budget for the additional components. Otherwise, pods will get stuck when node is drained
  #          values:
  #            kiali:
  #              service:
  #                type: LoadBalancer
  #            global:
  #              defaultPodDisruptionBudget:
  #                enabled: false
  #  EOT
  #}

  pack {
    name   = "csi-maas-volume"
    tag    = "1.0.x"
    uid    = data.spectrocloud_pack.csi-maas.id
    values = data.spectrocloud_pack.csi-maas.values
  }

  pack {
    name   = "cni-calico"
    tag    = "3.16.x"
    uid    = data.spectrocloud_pack.cni-maas.id
    values = data.spectrocloud_pack.cni-maas.values
  }

  pack {
    name   = "kubernetes"
    tag    = "1.18.x"
    uid    = data.spectrocloud_pack.k8s-maas.id
    values = data.spectrocloud_pack.k8s-maas.values
  }

  pack {
    name   = "ubuntu-maas"
    tag    = "LTS__18.4.x"
    uid    = data.spectrocloud_pack.ubuntu-maas.id
    values = data.spectrocloud_pack.ubuntu-maas.values
  }

}

