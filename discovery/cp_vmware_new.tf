# data "spectrocloud_pack" "csi-vsphere" {
#   name = "csi-vsphere-volume"
#   # version  = "1.0.x"
# }

# data "spectrocloud_pack" "cni-vsphere" {
#   name    = "cni-calico"
#   version = "3.16.0"
# }

# data "spectrocloud_pack" "k8s-vsphere" {
#   name    = "kubernetes"
#   version = "1.18.13"
# }

# data "spectrocloud_pack" "ubuntu-vsphere" {
#   name = "ubuntu-vsphere"
#   # version  = "1.0.x"
# }

resource "spectrocloud_cluster_profile" "prodvmware2" {
  name        = "ProdVMware2"
  description = "basic cp"
  cloud       = "vsphere"
  type        = "cluster"

  pack {
    name   = "csi-vsphere-volume"
    tag    = "1.0.x"
    uid    = data.spectrocloud_pack.csi-vsphere.id
    values = <<-EOT
      manifests:
        vsphere:

          #DiskFormat types : thin, zeroedthick and eagerzeroedthick
          diskformat: "thin"

          #If specified, the volume will be created on the datastore specified in the storage class.
          #This field is optional. If the datastore is not specified, then the volume will be created
          # on the datastore specified in the vSphere config file used to initialize the vSphere Cloud Provider.
          datastore: ""

          #Toggle for Default class
          isDefaultClass: "false"

          #Supported binding modes are Immediate, WaitForFirstConsumer
          volumeBindingMode: "Immediate"
    EOT
  }

  pack {
    name   = "cni-calico"
    tag    = "3.16.x"
    uid    = data.spectrocloud_pack.cni-vsphere.id
    values = data.spectrocloud_pack.cni-vsphere.values
  }

  pack {
    name   = "kubernetes"
    tag    = "1.18.13"
    uid    = data.spectrocloud_pack.k8s-vsphere.id
    values = <<-EOT
      pack:
        k8sHardening: True
        #CIDR Range for Pods in cluster
        # Note : This must not overlap with any of the host or service network
        podCIDR: "192.168.0.0/16"
        #CIDR notation IP range from which to assign service cluster IPs
        # Note : This must not overlap with any IP ranges assigned to nodes for pods.
        serviceClusterIpRange: "10.96.0.0/12"

      # KubeAdm customization for kubernetes hardening. Below config will be ignored if k8sHardening property above is disabled
      kubeadmconfig:
        apiServer:
          extraArgs:
            oidc-client-id: spectrocloud
            oidc-issuer-url: https://magentaauth.geo.pks.t-mobile.com/oauth/token
            oidc-username-claim: user_name
            oidc-username-prefix: "-"
            oidc-groups-claim: groups
            anonymous-auth: "true"
            insecure-port: "0"
            profiling: "false"
            disable-admission-plugins: "AlwaysAdmit"
            default-not-ready-toleration-seconds: "60"
            default-unreachable-toleration-seconds: "60"
            enable-admission-plugins: "AlwaysPullImages,NamespaceLifecycle,ServiceAccount,NodeRestriction,PodSecurityPolicy"
            audit-log-path: /var/log/apiserver/audit.log
            audit-policy-file: /etc/kubernetes/audit-policy.yaml
            audit-log-maxage: "30"
            audit-log-maxbackup: "10"
            audit-log-maxsize: "100"
            authorization-mode: RBAC,Node
            tls-cipher-suites: "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256"
          extraVolumes:
            - name: audit-log
              hostPath: /var/log/apiserver
              mountPath: /var/log/apiserver
              pathType: DirectoryOrCreate
            - name: audit-policy
              hostPath: /etc/kubernetes/audit-policy.yaml
              mountPath: /etc/kubernetes/audit-policy.yaml
              readOnly: true
              pathType: File
        controllerManager:
          extraArgs:
            profiling: "false"
            terminated-pod-gc-threshold: "25"
            pod-eviction-timeout: "1m0s"
            use-service-account-credentials: "true"
            feature-gates: "RotateKubeletServerCertificate=true"
            address: "0.0.0.0"
        scheduler:
          extraArgs:
            profiling: "false"
            address: "0.0.0.0"
        kubeletExtraArgs:
          read-only-port : "0"
          event-qps: "0"
          feature-gates: "RotateKubeletServerCertificate=true"
          protect-kernel-defaults: "true"
          tls-cipher-suites: "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305,TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_256_GCM_SHA384,TLS_RSA_WITH_AES_128_GCM_SHA256"
        files:
          - path: hardening/audit-policy.yaml
            targetPath: /etc/kubernetes/audit-policy.yaml
            targetOwner: "root:root"
            targetPermissions: "0600"
          - path: hardening/privileged-psp.yaml
            targetPath: /etc/kubernetes/hardening/privileged-psp.yaml
            targetOwner: "root:root"
            targetPermissions: "0600"
          - path: hardening/90-kubelet.conf
            targetPath: /etc/sysctl.d/90-kubelet.conf
            targetOwner: "root:root"
            targetPermissions: "0600"
        preKubeadmCommands:
          # For enabling 'protect-kernel-defaults' flag to kubelet, kernel parameters changes are required
          - 'echo "====> Applying kernel parameters for Kubelet"'
          - 'sysctl -p /etc/sysctl.d/90-kubelet.conf'
        postKubeadmCommands:
          # Apply the privileged PodSecurityPolicy on the first master node ; Otherwise, CNI (and other) pods won't come up
          - 'export KUBECONFIG=/etc/kubernetes/admin.conf'
          # Sometimes api server takes a little longer to respond. Retry if applying the pod-security-policy manifest fails
          - '[ -f "$KUBECONFIG" ] && { echo " ====> Applying PodSecurityPolicy" ; until $(kubectl apply -f /etc/kubernetes/hardening/privileged-psp.yaml > /dev/null ); do echo "Failed to apply PodSecurityPolicies, will retry in 5s" ; sleep 5 ; done ; } || echo "Skipping PodSecurityPolicy for worker nodes"'
    EOT
  }

  pack {
    name   = "ubuntu-vsphere"
    tag    = "LTS__18.4.x"
    uid    = data.spectrocloud_pack.ubuntu-vsphere.id
    values = data.spectrocloud_pack.ubuntu-vsphere.values
  }

}
