data "spectrocloud_cloudaccount_azure" "picard" {
  name = "azure-picard"
}

locals {
  azure_subscription_id = "8710ff2b-e468-434a-9a84-e522999f6b81"
  azure_resource_group  = "picard"
  azure_region          = "westus2"

  # cluster_ssh_public_key = <<-EOT
  #   ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDAUaBODDNpQxJJqXz/Q+afauM5EPFp4oDRrWzK/cGd92N+exkd+tEZdO7n3R+WAx0XTcPiVvfKctzekNS6f/ZMrFb5HAPvFJtnGNIE2sm+eryEnAH+Sc7ppZha3/MaSp/A2dm2IobYRvwl04sEi4w1K+I8Rtt+fBe3gV3wnP3E3yOiRx4G2XFC3T6x8MjdOkjO2v6fBluw1M1H2etp1m/n4D70UkeyVJyipcntz0ubHweU7yPNdNS3YkpExYIGhm97C4dyESHEw9PZVdLs1FBL6mW5Yb4qVbg5FkLljLFynh9jL8IAYal0pibAAH+Sk/Nd4865lVJ3lrm8nhBnjs1OEFA487rcxyInxJk/WwLEHvo88Ku9IlYq15Alr8N/JHHackV4kAH0yJNeLtwAysK2gI7Mb5uGnMTPrz73IZqXSxFqnU34Ow+vwu8fXBtXmHA5cUHyz0ARzpgx8A0e8L8SjdY/6dsFhSzGo7JoCElN7sEMo7iI4Wdo8CYdlT+OXizBf3pnM/wxRZclCeRDJpLtd6jl5swv7J5ocINEh1r3BllCyV8L7Xp5gw8IKT3ohz6rliGJwwlq/emqY52eB3wweTLRm30z3h3aQa3YeAR+2JgvWlrJ3YWsYYCLRhSQTfYmpgUkoZIcfB2xkZzp6cyooM0i5Obz313HsxwBHOmNrw== spectro@spectro
  # EOT
}


resource "spectrocloud_cluster_azure" "cluster" {
  name = "az-picard-2"

  cluster_profile {
    id = spectrocloud_cluster_profile.azure.id
    #pack {
    #  pack:
    #    k8sHardening: True
    #    #CIDR Range for Pods in cluster
    #    # Note : This must not overlap with any of the host or service network
    #    podCIDR: "192.168.0.0/16"
    #    #CIDR notation IP range from which to assign service cluster IPs
    #    # Note : This must not overlap with any IP ranges assigned to nodes for pods.
    #    serviceClusterIpRange: "10.96.0.0/12"

    ## KubeAdm customization for kubernetes hardening. Below config will be ignored if k8sHardening property above is disabled
    #  kubeadmconfig:
    #    apiServer:
    #      extraArgs:
    #        oidc-client-id: "0oa4fe1y3zjc2W2nc5d6"
    #        oidc-groups-claim: "groups"
    #        oidc-issuer-url: "https://dev-6428100.okta.com/oauth2/default"
    #        oidc-username-claim: "email"
    #        oidc-username-prefix: "-"
    #        # Note : secure-port flag is used during kubeadm init. Do not change this flag on a running cluster
    #        secure-port: "6443"
    #        anonymous-auth: "true"
    #        insecure-port: "0"
    #        profiling: "false"
    #        disable-admission-plugins: "AlwaysAdmit"
    #        default-not-ready-toleration-seconds: "60"
    #        default-unreachable-toleration-seconds: "60"
    #        enable-admission-plugins: "AlwaysPullImages,NamespaceLifecycle,ServiceAccount,NodeRestriction,PodSecurityPolicy"
    #        audit-log-path: /var/log/apiserver/audit.log
    #        audit-policy-file: /etc/kubernetes/audit-policy.yaml
    #        audit-log-maxage: "30"
    #        audit-log-maxbackup: "10"
    #        audit-log-maxsize: "100"
    #        authorization-mode: RBAC,Node
    #        tls-cipher-suites: "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256"
    #      extraVolumes:
    #        - name: audit-log
    #          hostPath: /var/log/apiserver
    #          mountPath: /var/log/apiserver
    #          pathType: DirectoryOrCreate
    #        - name: audit-policy
    #          hostPath: /etc/kubernetes/audit-policy.yaml
    #          mountPath: /etc/kubernetes/audit-policy.yaml
    #          readOnly: true
    #          pathType: File
    #    controllerManager:
    #      extraArgs:
    #        profiling: "false"
    #        terminated-pod-gc-threshold: "25"
    #        pod-eviction-timeout: "1m0s"
    #        use-service-account-credentials: "true"
    #        feature-gates: "RotateKubeletServerCertificate=true"
    #    scheduler:
    #      extraArgs:
    #        profiling: "false"
    #    kubeletExtraArgs:
    #      read-only-port : "0"
    #      event-qps: "0"
    #      feature-gates: "RotateKubeletServerCertificate=true"
    #      protect-kernel-defaults: "true"
    #      tls-cipher-suites: "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256"
    #    files:
    #      - path: hardening/audit-policy.yaml
    #        targetPath: /etc/kubernetes/audit-policy.yaml
    #        targetOwner: "root:root"
    #        targetPermissions: "0600"
    #      - path: hardening/privileged-psp.yaml
    #        targetPath: /etc/kubernetes/hardening/privileged-psp.yaml
    #        targetOwner: "root:root"
    #        targetPermissions: "0600"
    #      - path: hardening/90-kubelet.conf
    #        targetPath: /etc/sysctl.d/90-kubelet.conf
    #        targetOwner: "root:root"
    #        targetPermissions: "0600"
    #    preKubeadmCommands:
    #      # For enabling 'protect-kernel-defaults' flag to kubelet, kernel parameters changes are required
    #      - 'echo "====> Applying kernel parameters for Kubelet"'
    #      - 'sysctl -p /etc/sysctl.d/90-kubelet.conf'
    #    postKubeadmCommands:
    #      # Apply the privileged PodSecurityPolicy on the first master node ; Otherwise, CNI (and other) pods won't come up
    #      # Sometimes api server takes a little longer to respond. Retry if applying the pod-security-policy manifest fails
    #      - 'export KUBECONFIG=/etc/kubernetes/admin.conf && [ -f "$KUBECONFIG" ] && { echo " ====> Applying PodSecurityPolicy" ; until $(kubectl apply -f /etc/kubernetes/hardening/privileged-psp.yaml > /dev/null ); do echo "Failed to apply PodSecurityPolicies, will retry in 5s" ; sleep 5 ; done ; } || echo "Skipping PodSecurityPolicy for worker nodes"'

    ## Client configuration to add OIDC based authentication flags in kubeconfig
    #  clientConfig:
    #    oidc-issuer-url: "{{ .spectro.pack.kubernetes.kubeadmconfig.apiServer.extraArgs.oidc-issuer-url }}"
    #    oidc-client-id: "{{ .spectro.pack.kubernetes.kubeadmconfig.apiServer.extraArgs.oidc-client-id }}"
    #    oidc-client-secret: KoBmGDtkrgXS3KenKGTi_vj9YMwN_QPo1BvsjV2j
    #    oidc-extra-scope: profile,email,groups
    #      }
  }

  cloud_account_id = data.spectrocloud_cloudaccount_azure.picard.id

  cloud_config {
    subscription_id = local.azure_subscription_id
    resource_group  = local.azure_resource_group
    region          = local.azure_region
    ssh_key         = local.cluster_ssh_public_key
  }

  # To override or specify values for a cluster:

  # pack {
  #   name   = "spectro-byo-manifest"
  #   tag    = "1.0.x"
  #   values = <<-EOT
  #     manifests:
  #       byo-manifest:
  #         contents: |
  #           # Add manifests here
  #           apiVersion: v1
  #           kind: Namespace
  #           metadata:
  #             labels:
  #               app: wordpress
  #               app2: wordpress2
  #             name: wordpress
  #   EOT
  # }

  machine_pool {
    control_plane           = true
    control_plane_as_worker = true
    name                    = "master-pool"
    count                   = 1
    azs                     = []
    instance_type           = "Standard_D2_v3"
    disk {
      size_gb = 65
      type    = "Standard_LRS"
    }
  }

  machine_pool {
    name          = "new-worker-pool"
    count         = 1
    instance_type = "Standard_B4ms"
    azs           = ["1"]
    disk {
      size_gb = 60
      type    = "Standard_LRS"
    }
  }

  machine_pool {
    name          = "gpu-pool-2"
    count         = 1
    instance_type = "Standard_B4ms"
    azs           = ["1"]
    disk {
      size_gb = 60
      type    = "Standard_LRS"
    }
  }

}
