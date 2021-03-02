# If looking up a cluster profile instead of creating a new one
# data "spectrocloud_cluster_profile" "profile" {
#   # id = <uid>
#   name = var.cluster_cluster_profile_name
# }


resource "spectrocloud_cluster_profile" "ifcvmware" {
  name        = "IFCVMware"
  description = "basic cp"
  cloud       = "vsphere"
  type        = "cluster"

  # pack {
  #   name   = "vault"
  #   tag    = "0.6.x"
  #   uid    = data.spectrocloud_pack.vault.id
  #   values = data.spectrocloud_pack.vault.values
  # }

  #pack {
  #  name   = "nginx"
  #  tag    = "0.26.x"
  #  uid    = data.spectrocloud_pack.nginx-vsphere.id
  #  values = <<-EOT
  #    pack:
  #      #The namespace (on the target cluster) to install this chart
  #      #When not found, a new namespace will be created
  #      namespace: "nginx"

  #    charts:
  #      nginx-ingress:
  #        fullnameOverride: "nginx-ingress"
  #        controller:
  #          fullnameOverride: nginx-ingress.controller
  #          name: controller
  #          image:
  #            repository: quay.io/kubernetes-ingress-controller/nginx-ingress-controller
  #            tag: "0.26.1"
  #            pullPolicy: IfNotPresent
  #            # www-data -> uid 33
  #            runAsUser: 33
  #            allowPrivilegeEscalation: true

  #          # Configures the ports the nginx-controller listens on
  #          containerPort:
  #            http: 80
  #            https: 443

  #          # Will add custom configuration options to Nginx https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
  #          config: {}

  #          # Will add custom headers before sending traffic to backends according to https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/customization/custom-headers
  #          proxySetHeaders: {}

  #          # Will add custom headers before sending response traffic to the client according to: https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#add-headers
  #          addHeaders: {}

  #          # Required for use with CNI based kubernetes installations (such as ones set up by kubeadm),
  #          # since CNI and hostport don't mix yet. Can be deprecated once https://github.com/kubernetes/kubernetes/issues/23920
  #          # is merged
  #          hostNetwork: false

  #          # Optionally change this to ClusterFirstWithHostNet in case you have 'hostNetwork: true'.
  #          # By default, while using host network, name resolution uses the host's DNS. If you wish nginx-controller
  #          # to keep resolving names inside the k8s network, use ClusterFirstWithHostNet.
  #          dnsPolicy: ClusterFirst

  #          # Bare-metal considerations via the host network https://kubernetes.github.io/ingress-nginx/deploy/baremetal/#via-the-host-network
  #          # Ingress status was blank because there is no Service exposing the NGINX Ingress controller in a configuration using the host network, the default --publish-service flag used in standard cloud setups does not apply
  #          reportNodeInternalIp: false

  #          ## Use host ports 80 and 443
  #          daemonset:
  #            useHostPort: false

  #            hostPorts:
  #              http: 80
  #              https: 443

  #          ## Required only if defaultBackend.enabled = false
  #          ## Must be <namespace>/<service_name>
  #          ##
  #          defaultBackendService: ""

  #          ## Election ID to use for status update
  #          ##
  #          electionID: ingress-controller-leader

  #          ## Name of the ingress class to route through this controller
  #          ##
  #          ingressClass: nginx

  #          # labels to add to the pod container metadata
  #          podLabels: {}
  #          #  key: value

  #          ## Security Context policies for controller pods
  #          ## See https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/ for
  #          ## notes on enabling and using sysctls
  #          ##
  #          podSecurityContext: {}

  #          ## Allows customization of the external service
  #          ## the ingress will be bound to via DNS
  #          publishService:
  #            enabled: true
  #            ## Allows overriding of the publish service to bind to
  #            ## Must be <namespace>/<service_name>
  #            ##
  #            pathOverride: ""

  #          ## Limit the scope of the controller
  #          ##
  #          scope:
  #            enabled: false
  #            namespace: ""   # defaults to .Release.Namespace

  #          ## Allows customization of the configmap / nginx-configmap namespace
  #          ##
  #          configMapNamespace: ""   # defaults to .Release.Namespace

  #          ## Allows customization of the tcp-services-configmap namespace
  #          ##
  #          tcp:
  #            configMapNamespace: ""   # defaults to .Release.Namespace

  #          ## Allows customization of the udp-services-configmap namespace
  #          ##
  #          udp:
  #            configMapNamespace: ""   # defaults to .Release.Namespace

  #          ## Additional command line arguments to pass to nginx-ingress-controller
  #          ## E.g. to specify the default SSL certificate you can use
  #          ## extraArgs:
  #          ##   default-ssl-certificate: "<namespace>/<secret_name>"
  #          extraArgs: {}

  #          ## Additional environment variables to set
  #          extraEnvs: []
  #          # extraEnvs:
  #          #   - name: FOO
  #          #     valueFrom:
  #          #       secretKeyRef:
  #          #         key: FOO
  #          #         name: secret-resource

  #          ## DaemonSet or Deployment
  #          ##
  #          kind: Deployment

  #          ## Annotations to be added to the controller deployment
  #          ##
  #          deploymentAnnotations: {}

  #          # The update strategy to apply to the Deployment or DaemonSet
  #          ##
  #          updateStrategy: {}
  #          #  rollingUpdate:
  #          #    maxUnavailable: 1
  #          #  type: RollingUpdate

  #          # minReadySeconds to avoid killing pods before we are ready
  #          ##
  #          minReadySeconds: 0


  #          ## Node tolerations for server scheduling to nodes with taints
  #          ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  #          ##
  #          tolerations: []
  #          #  - key: "key"
  #          #    operator: "Equal|Exists"
  #          #    value: "value"
  #          #    effect: "NoSchedule|PreferNoSchedule|NoExecute(1.6 only)"

  #          ## Affinity and anti-affinity
  #          ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  #          ##
  #          affinity: {}
  #            # # An example of preferred pod anti-affinity, weight is in the range 1-100
  #            # podAntiAffinity:
  #            #   preferredDuringSchedulingIgnoredDuringExecution:
  #            #   - weight: 100
  #            #     podAffinityTerm:
  #            #       labelSelector:
  #            #         matchExpressions:
  #            #         - key: app
  #            #           operator: In
  #            #           values:
  #            #           - nginx-ingress
  #            #       topologyKey: kubernetes.io/hostname

  #            # # An example of required pod anti-affinity
  #            # podAntiAffinity:
  #            #   requiredDuringSchedulingIgnoredDuringExecution:
  #            #   - labelSelector:
  #            #       matchExpressions:
  #            #       - key: app
  #            #         operator: In
  #            #         values:
  #          #         - nginx-ingress
  #          #     topologyKey: "kubernetes.io/hostname"

  #          ## terminationGracePeriodSeconds
  #          ##
  #          terminationGracePeriodSeconds: 60

  #          ## Node labels for controller pod assignment
  #          ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  #          ##
  #          nodeSelector: {}

  #          ## Liveness and readiness probe values
  #          ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  #          ##
  #          livenessProbe:
  #            failureThreshold: 3
  #            initialDelaySeconds: 10
  #            periodSeconds: 10
  #            successThreshold: 1
  #            timeoutSeconds: 1
  #            port: 10254
  #          readinessProbe:
  #            failureThreshold: 3
  #            initialDelaySeconds: 10
  #            periodSeconds: 10
  #            successThreshold: 1
  #            timeoutSeconds: 1
  #            port: 10254

  #          ## Annotations to be added to controller pods
  #          ##
  #          podAnnotations: {}

  #          replicaCount: 1

  #          minAvailable: 1

  #          resources:
  #            limits:
  #              cpu: 500m
  #              memory: 500Mi
  #            requests:
  #              cpu: 100m
  #              memory: 64Mi

  #          autoscaling:
  #            enabled: true
  #            minReplicas: 1
  #            maxReplicas: 3
  #            targetCPUUtilizationPercentage: 70
  #            targetMemoryUtilizationPercentage: 80

  #          ## Override NGINX template
  #          customTemplate:
  #            configMapName: ""
  #            configMapKey: ""

  #          service:
  #            enabled: true

  #            annotations: {}
  #            labels: {}
  #            ## Deprecated, instead simply do not provide a clusterIP value
  #            omitClusterIP: false
  #            # clusterIP: ""

  #            ## List of IP addresses at which the controller services are available
  #            ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
  #            ##
  #            externalIPs: []

  #            loadBalancerIP: ""
  #            loadBalancerSourceRanges: []

  #            enableHttp: true
  #            enableHttps: true

  #            ## Set external traffic policy to: "Local" to preserve source IP on
  #            ## providers supporting it
  #            ## Ref: https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-typeloadbalancer
  #            externalTrafficPolicy: ""

  #            healthCheckNodePort: 0

  #            ports:
  #              http: 80
  #              https: 443

  #            targetPorts:
  #              http: http
  #              https: https

  #            type: LoadBalancer

  #            # type: NodePort
  #            # nodePorts:
  #            #   http: 32080
  #            #   https: 32443
  #            #   tcp:
  #            #     8080: 32808
  #            nodePorts:
  #              http: ""
  #              https: ""
  #              tcp: {}
  #              udp: {}

  #          extraContainers: []
  #          ## Additional containers to be added to the controller pod.
  #          ## See https://github.com/lemonldap-ng-controller/lemonldap-ng-controller as example.
  #          #  - name: my-sidecar
  #          #    image: nginx:latest
  #          #  - name: lemonldap-ng-controller
  #          #    image: lemonldapng/lemonldap-ng-controller:0.2.0
  #          #    args:
  #          #      - /lemonldap-ng-controller
  #          #      - --alsologtostderr
  #          #      - --configmap=$(POD_NAMESPACE)/lemonldap-ng-configuration
  #          #    env:
  #          #      - name: POD_NAME
  #          #        valueFrom:
  #          #          fieldRef:
  #          #            fieldPath: metadata.name
  #          #      - name: POD_NAMESPACE
  #          #        valueFrom:
  #          #          fieldRef:
  #          #            fieldPath: metadata.namespace
  #          #    volumeMounts:
  #          #    - name: copy-portal-skins
  #          #      mountPath: /srv/var/lib/lemonldap-ng/portal/skins

  #          extraVolumeMounts: []
  #          ## Additional volumeMounts to the controller main container.
  #          #  - name: copy-portal-skins
  #          #   mountPath: /var/lib/lemonldap-ng/portal/skins

  #          extraVolumes: []
  #          ## Additional volumes to the controller pod.
  #          #  - name: copy-portal-skins
  #          #    emptyDir: {}

  #          extraInitContainers: []
  #          ## Containers, which are run before the app containers are started.
  #          # - name: init-myservice
  #          #   image: busybox
  #          #   command: ['sh', '-c', 'until nslookup myservice; do echo waiting for myservice; sleep 2; done;']

  #          admissionWebhooks:
  #            enabled: false
  #            failurePolicy: Fail
  #            port: 8443

  #            service:
  #              annotations: {}
  #              ## Deprecated, instead simply do not provide a clusterIP value
  #              omitClusterIP: false
  #              # clusterIP: ""
  #              externalIPs: []
  #              loadBalancerIP: ""
  #              loadBalancerSourceRanges: []
  #              servicePort: 443
  #              type: ClusterIP

  #            patch:
  #              enabled: true
  #              image:
  #                repository: jettech/kube-webhook-certgen
  #                tag: v1.0.0
  #                pullPolicy: IfNotPresent
  #              ## Provide a priority class name to the webhook patching job
  #              ##
  #              priorityClassName: ""
  #              podAnnotations: {}
  #              nodeSelector: {}

  #          metrics:
  #            port: 10254
  #            # if this port is changed, change healthz-port: in extraArgs: accordingly
  #            enabled: true

  #            service:
  #              annotations: {}
  #              # prometheus.io/scrape: "true"
  #              # prometheus.io/port: "10254"

  #              ## Deprecated, instead simply do not provide a clusterIP value
  #              omitClusterIP: false
  #              # clusterIP: ""

  #              ## List of IP addresses at which the stats-exporter service is available
  #              ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
  #              ##
  #              externalIPs: []

  #              loadBalancerIP: ""
  #              loadBalancerSourceRanges: []
  #              servicePort: 9913
  #              type: ClusterIP

  #            serviceMonitor:
  #              enabled: false
  #              additionalLabels: {}
  #              namespace: ""
  #              namespaceSelector: {}
  #              # Default: scrape .Release.Namespace only
  #              # To scrape all, use the following:
  #              # namespaceSelector:
  #              #   any: true
  #              scrapeInterval: 30s
  #              # honorLabels: true

  #            prometheusRule:
  #              enabled: false
  #              additionalLabels: {}
  #              namespace: ""
  #              rules: []
  #                # # These are just examples rules, please adapt them to your needs
  #                # - alert: TooMany500s
  #                #   expr: 100 * ( sum( nginx_ingress_controller_requests{status=~"5.+"} ) / sum(nginx_ingress_controller_requests) ) > 5
  #                #   for: 1m
  #                #   labels:
  #                #     severity: critical
  #                #   annotations:
  #                #     description: Too many 5XXs
  #                #     summary: More than 5% of the all requests did return 5XX, this require your attention
  #                # - alert: TooMany400s
  #                #   expr: 100 * ( sum( nginx_ingress_controller_requests{status=~"4.+"} ) / sum(nginx_ingress_controller_requests) ) > 5
  #                #   for: 1m
  #                #   labels:
  #                #     severity: critical
  #                #   annotations:
  #              #     description: Too many 4XXs
  #              #     summary: More than 5% of the all requests did return 4XX, this require your attention


  #          lifecycle: {}

  #          priorityClassName: ""

  #        ## Rollback limit
  #        ##
  #        revisionHistoryLimit: 10

  #        ## Default 404 backend
  #        ##
  #        defaultBackend:

  #          ## If false, controller.defaultBackendService must be provided
  #          ##
  #          enabled: true

  #          name: default-backend
  #          image:
  #            repository: k8s.gcr.io/defaultbackend-amd64
  #            tag: "1.5"
  #            pullPolicy: IfNotPresent
  #            # nobody user -> uid 65534
  #            runAsUser: 65534

  #          extraArgs: {}

  #          serviceAccount:
  #            create: true
  #            name:
  #          ## Additional environment variables to set for defaultBackend pods
  #          extraEnvs: []

  #          port: 8080

  #          ## Readiness and liveness probes for default backend
  #          ## Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/
  #          ##
  #          livenessProbe:
  #            failureThreshold: 3
  #            initialDelaySeconds: 30
  #            periodSeconds: 10
  #            successThreshold: 1
  #            timeoutSeconds: 5
  #          readinessProbe:
  #            failureThreshold: 6
  #            initialDelaySeconds: 0
  #            periodSeconds: 5
  #            successThreshold: 1
  #            timeoutSeconds: 5

  #          ## Node tolerations for server scheduling to nodes with taints
  #          ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  #          ##
  #          tolerations: []
  #          #  - key: "key"
  #          #    operator: "Equal|Exists"
  #          #    value: "value"
  #          #    effect: "NoSchedule|PreferNoSchedule|NoExecute(1.6 only)"

  #          affinity: {}

  #          ## Security Context policies for controller pods
  #          ## See https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/ for
  #          ## notes on enabling and using sysctls
  #          ##
  #          podSecurityContext: {}

  #          # labels to add to the pod container metadata
  #          podLabels: {}
  #          #  key: value

  #          ## Node labels for default backend pod assignment
  #          ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
  #          ##
  #          nodeSelector: {}

  #          ## Annotations to be added to default backend pods
  #          ##
  #          podAnnotations: {}

  #          replicaCount: 1

  #          minAvailable: 1

  #          resources:
  #            limits:
  #              cpu: 300m
  #              memory: 400Mi
  #            requests:
  #              cpu: 10m
  #              memory: 20Mi

  #          service:
  #            annotations: {}
  #            ## Deprecated, instead simply do not provide a clusterIP value
  #            omitClusterIP: false
  #            # clusterIP: ""

  #            ## List of IP addresses at which the default backend service is available
  #            ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
  #            ##
  #            externalIPs: []

  #            loadBalancerIP: ""
  #            loadBalancerSourceRanges: []
  #            servicePort: 80
  #            type: ClusterIP

  #          priorityClassName: ""

  #        ## Enable RBAC as per https://github.com/kubernetes/ingress/tree/master/examples/rbac/nginx and https://github.com/kubernetes/ingress/issues/266
  #        rbac:
  #          create: true

  #        # If true, create & use Pod Security Policy resources
  #        # https://kubernetes.io/docs/concepts/policy/pod-security-policy/
  #        podSecurityPolicy:
  #          enabled: false

  #        serviceAccount:
  #          create: true
  #          name:

  #        ## Optional array of imagePullSecrets containing private registry credentials
  #        ## Ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
  #        imagePullSecrets: []
  #        # - name: secretName

  #        # TCP service key:value pairs
  #        # Ref: https://github.com/kubernetes/contrib/tree/master/ingress/controllers/nginx/examples/tcp
  #        ##
  #        tcp: {}
  #        #  8080: "default/example-tcp-svc:9000"

  #        # UDP service key:value pairs
  #        # Ref: https://github.com/kubernetes/contrib/tree/master/ingress/controllers/nginx/examples/udp
  #        ##
  #        udp: {}
  #        #  53: "kube-system/kube-dns:53"
  #  EOT
  #}

  #pack {
  #  name   = "lb-metallb"
  #  tag    = "0.8.x"
  #  uid    = data.spectrocloud_pack.lbmetal-vsphere.id
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
          isDefaultClass: "true"

          #Supported binding modes are Immediate, WaitForFirstConsumer
          volumeBindingMode: "WaitForFirstConsumer"
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
    tag    = "1.18.x"
    uid    = data.spectrocloud_pack.k8s-vsphere.id
    values = data.spectrocloud_pack.k8s-vsphere.values
  }

  pack {
    name   = "ubuntu-vsphere"
    tag    = "LTS__18.4.x"
    uid    = data.spectrocloud_pack.ubuntu-vsphere.id
    values = data.spectrocloud_pack.ubuntu-vsphere.values
  }

}
