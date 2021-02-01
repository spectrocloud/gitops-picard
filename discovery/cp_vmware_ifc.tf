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

  pack {
    name   = "prometheus-operator"
    tag    = "9.7.x"
    uid    = data.spectrocloud_pack.prometheus-vsphere.id
    values = <<-EOT
      pack:
        #The namespace (on the target cluster) to install this chart
        #When not found, a new namespace will be created
        namespace: "monitoring"

      charts:
        prometheus-operator:

          # Default values for prometheus-operator.
          # This is a YAML-formatted file.
          # Declare variables to be passed into your templates.

          ## Provide a name in place of prometheus-operator for `app:` labels
          ##
          nameOverride: ""

          ## Provide a name to substitute for the full names of resources
          ##
          fullnameOverride: "prometheus-operator"

          ## Labels to apply to all resources
          ##
          commonLabels: {}
          # scmhash: abc123
          # myLabel: aakkmd

          ## Create default rules for monitoring the cluster
          ##
          defaultRules:
            create: true
            rules:
              alertmanager: true
              etcd: true
              general: true
              k8s: true
              kubeApiserver: true
              kubePrometheusNodeAlerting: true
              kubePrometheusNodeRecording: true
              kubernetesAbsent: true
              kubernetesApps: true
              kubernetesResources: true
              kubernetesStorage: true
              kubernetesSystem: true
              kubeScheduler: true
              network: true
              node: true
              prometheus: true
              prometheusOperator: true
              time: true
              genericNetworkAlerts: true
              genericNodeAlerts: true
              nginxAlerts: false

            ## Labels for default rules
            labels: {}
            ## Annotations for default rules
            annotations: {}

          ## Provide custom recording or alerting rules to be deployed into the cluster.
          ##
          additionalPrometheusRules: []
          #  - name: my-rule-file
          #    groups:
          #      - name: my_group
          #        rules:
          #        - record: my_record
          #          expr: 100 * my_record

          ##
          global:
            rbac:
              create: true
              pspEnabled: true

            ## Reference to one or more secrets to be used when pulling images
            ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
            ##
            imagePullSecrets: []
            # - name: "image-pull-secret"

          ## Configuration for alertmanager
          ## ref: https://prometheus.io/docs/alerting/alertmanager/
          ##
          alertmanager:

            ## Deploy alertmanager
            ##
            enabled: true

            ## Service account for Alertmanager to use.
            ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
            ##
            serviceAccount:
              create: true
              name: ""

            ## Configure pod disruption budgets for Alertmanager
            ## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/#specifying-a-poddisruptionbudget
            ## This configuration is immutable once created and will require the PDB to be deleted to be changed
            ## https://github.com/kubernetes/kubernetes/issues/45398
            ##
            podDisruptionBudget:
              enabled: false
              minAvailable: 1
              maxUnavailable: ""

            ## Alertmanager configuration directives
            ## ref: https://prometheus.io/docs/alerting/configuration/#configuration-file
            ##      https://prometheus.io/webtools/alerting/routing-tree-editor/
            ##
            config:
              global:
                resolve_timeout: 5m
              route:
                group_by: ['job']
                group_wait: 30s
                group_interval: 5m
                repeat_interval: 4h
                receiver: 'null'
                # receiver: 'prom-alert'
                routes:
                  - match:
                      alertname: Watchdog
                    receiver: 'null'
                    # receiver: 'prom-alert'
              receivers:
                - name: 'null'
              # - name: prom-alert
              #   email_configs:
              #   - to: <reciever>@<domainname>.com
              #     send_resolved: true
              #     from: <sender>@<domainname>.com
              #     # Your smtp server address
              #     smarthost: smtp.<domainname>.com:587
              #     auth_username: <sender>@<domainname>.com
              #     auth_identity: <sender>@<domainname>.com
              #     auth_password: <sender_passwd>

            ## Pass the Alertmanager configuration directives through Helm's templating
            ## engine. If the Alertmanager configuration contains Alertmanager templates,
            ## they'll need to be properly escaped so that they are not interpreted by
            ## Helm
            ## ref: https://helm.sh/docs/developing_charts/#using-the-tpl-function
            ##      https://prometheus.io/docs/alerting/configuration/#%3Ctmpl_string%3E
            ##      https://prometheus.io/docs/alerting/notifications/
            ##      https://prometheus.io/docs/alerting/notification_examples/
            tplConfig: false

            ## Alertmanager template files to format alerts
            ## ref: https://prometheus.io/docs/alerting/notifications/
            ##      https://prometheus.io/docs/alerting/notification_examples/
            ##
            templateFiles: {}
            #
            ## An example template:
            #   template_1.tmpl: |-
            #       {{ define "cluster" }}{{ .ExternalURL | reReplaceAll ".*alertmanager\\.(.*)" "$1" }}{{ end }}
            #
            #       {{ define "slack.myorg.text" }}
            #       {{- $root := . -}}
            #       {{ range .Alerts }}
            #         *Alert:* {{ .Annotations.summary }} - `{{ .Labels.severity }}`
            #         *Cluster:*  {{ template "cluster" $root }}
            #         *Description:* {{ .Annotations.description }}
            #         *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
            #         *Runbook:* <{{ .Annotations.runbook }}|:spiral_note_pad:>
            #         *Details:*
            #           {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            #           {{ end }}

            ingress:
              enabled: true

              annotations: {}

              labels: {}

              ## Hosts must be provided if Ingress is enabled.
              ##
              hosts:
              - alerts.cluster1.discovery.spectrocloud.com

              ## Paths to use for ingress rules - one path should match the alertmanagerSpec.routePrefix
              ##
              paths: []
              # - /

              ## TLS configuration for Alertmanager Ingress
              ## Secret must be manually created in the namespace
              ##
              tls: []
              # - secretName: alertmanager-general-tls
              #   hosts:
              #   - alertmanager.example.com

            ## Configuration for Alertmanager secret
            ##
            secret:
              annotations: {}

            ## Configuration for Alertmanager service
            ##
            service:
              annotations: {}
              labels: {}
              clusterIP: ""

              ## Port for Alertmanager Service to listen on
              ##
              port: 9093
              ## Port to expose on each node
              ## Only used if service.type is 'NodePort'
              ##
              nodePort: 30903
              ## List of IP addresses at which the Prometheus server service is available
              ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
              ##
              externalIPs: []
              loadBalancerIP: ""
              loadBalancerSourceRanges: []
              ## Service type
              ##
              type: ClusterIP

            ## If true, create a serviceMonitor for alertmanager
            ##
            serviceMonitor:
              ## Scrape interval. If not set, the Prometheus default scrape interval is used.
              ##
              interval: ""
              selfMonitor: true

              ## 	metric relabel configs to apply to samples before ingestion.
              ##
              metricRelabelings: []
              # - action: keep
              #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
              #   sourceLabels: [__name__]

              # 	relabel configs to apply to samples before ingestion.
              ##
              relabelings: []
              # - sourceLabels: [__meta_kubernetes_pod_node_name]
              #   separator: ;
              #   regex: ^(.*)$
              #   targetLabel: nodename
              #   replacement: $1
              #   action: replace

            ## Settings affecting alertmanagerSpec
            ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#alertmanagerspec
            ##
            alertmanagerSpec:
              ## Standard object’s metadata. More info: https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#metadata
              ## Metadata Labels and Annotations gets propagated to the Alertmanager pods.
              ##
              podMetadata: {}

              ## Image of Alertmanager
              ##
              image:
                repository: quay.io/prometheus/alertmanager
                tag: v0.19.0

              ## If true then the user will be responsible to provide a secret with alertmanager configuration
              ## So when true the config part will be ignored (including templateFiles) and the one in the secret will be used
              ##
              useExistingSecret: false

              ## Secrets is a list of Secrets in the same namespace as the Alertmanager object, which shall be mounted into the
              ## Alertmanager Pods. The Secrets are mounted into /etc/alertmanager/secrets/.
              ##
              secrets: []

              ## ConfigMaps is a list of ConfigMaps in the same namespace as the Alertmanager object, which shall be mounted into the Alertmanager Pods.
              ## The ConfigMaps are mounted into /etc/alertmanager/configmaps/.
              ##
              configMaps: []

              ## ConfigSecret is the name of a Kubernetes Secret in the same namespace as the Alertmanager object, which contains configuration for
              ## this Alertmanager instance. Defaults to 'alertmanager-' The secret is mounted into /etc/alertmanager/config.
              ##
              # configSecret:

              ## Define Log Format
              # Use logfmt (default) or json-formatted logging
              logFormat: logfmt

              ## Log level for Alertmanager to be configured with.
              ##
              logLevel: info

              ## Size is the expected size of the alertmanager cluster. The controller will eventually make the size of the
              ## running cluster equal to the expected size.
              replicas: 1

              ## Time duration Alertmanager shall retain data for. Default is '120h', and must match the regular expression
              ## [0-9]+(ms|s|m|h) (milliseconds seconds minutes hours).
              ##
              retention: 120h

              ## Storage is the definition of how storage will be used by the Alertmanager instances.
              ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/user-guides/storage.md
              ##
              storage: {}
              # volumeClaimTemplate:
              #   spec:
              #     storageClassName: gluster
              #     accessModes: ["ReadWriteOnce"]
              #     resources:
              #       requests:
              #         storage: 50Gi
              #   selector: {}


              ## 	The external URL the Alertmanager instances will be available under. This is necessary to generate correct URLs. This is necessary if Alertmanager is not served from root of a DNS name.	string	false
              ##
              externalUrl:

              ## 	The route prefix Alertmanager registers HTTP handlers for. This is useful, if using ExternalURL and a proxy is rewriting HTTP routes of a request, and the actual ExternalURL is still true,
              ## but the server serves requests under a different route prefix. For example for use with kubectl proxy.
              ##
              routePrefix: /

              ## If set to true all actions on the underlying managed objects are not going to be performed, except for delete actions.
              ##
              paused: false

              ## Define which Nodes the Pods are scheduled on.
              ## ref: https://kubernetes.io/docs/user-guide/node-selection/
              ##
              nodeSelector: {}

              ## Define resources requests and limits for single Pods.
              ## ref: https://kubernetes.io/docs/user-guide/compute-resources/
              ##
              resources: {}
              # requests:
              #   memory: 400Mi

              ## Pod anti-affinity can prevent the scheduler from placing Prometheus replicas on the same node.
              ## The default value "soft" means that the scheduler should *prefer* to not schedule two replica pods onto the same node but no guarantee is provided.
              ## The value "hard" means that the scheduler is *required* to not schedule two replica pods onto the same node.
              ## The value "" will disable pod anti-affinity so that no anti-affinity rules will be configured.
              ##
              podAntiAffinity: ""

              ## If anti-affinity is enabled sets the topologyKey to use for anti-affinity.
              ## This can be changed to, for example, failure-domain.beta.kubernetes.io/zone
              ##
              podAntiAffinityTopologyKey: kubernetes.io/hostname

              ## Assign custom affinity rules to the alertmanager instance
              ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
              ##
              affinity: {}
              # nodeAffinity:
              #   requiredDuringSchedulingIgnoredDuringExecution:
              #     nodeSelectorTerms:
              #     - matchExpressions:
              #       - key: kubernetes.io/e2e-az-name
              #         operator: In
              #         values:
              #         - e2e-az1
              #         - e2e-az2

              ## If specified, the pod's tolerations.
              ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
              ##
              tolerations: []
              # - key: "key"
              #   operator: "Equal"
              #   value: "value"
              #   effect: "NoSchedule"

              ## SecurityContext holds pod-level security attributes and common container settings.
              ## This defaults to non root user with uid 1000 and gid 2000.	*v1.PodSecurityContext	false
              ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
              ##
              securityContext:
                runAsNonRoot: true
                runAsUser: 1000
                fsGroup: 2000

              ## ListenLocal makes the Alertmanager server listen on loopback, so that it does not bind against the Pod IP.
              ## Note this is only for the Alertmanager UI, not the gossip communication.
              ##
              listenLocal: false

              ## Containers allows injecting additional containers. This is meant to allow adding an authentication proxy to an Alertmanager pod.
              ##
              containers: []

              ## Priority class assigned to the Pods
              ##
              priorityClassName: ""

              ## AdditionalPeers allows injecting a set of additional Alertmanagers to peer with to form a highly available cluster.
              ##
              additionalPeers: []

              ## PortName to use for Alert Manager.
              ##
              portName: "web"


          ## Using default values from https://github.com/helm/charts/blob/master/stable/grafana/values.yaml
          ##
          grafana:
            enabled: true

            ## Deploy default dashboards.
            ##
            defaultDashboardsEnabled: true

            # Added for injecting proxy related setting from PodPreset
            podLabels:
              spectrocloud.com/connection: proxy

            fullnameOverride: "grafana"

            adminPassword: welcome123
            plugins:
              - grafana-piechart-panel

            service:
              type: ClusterIP
              port: 80
              targetPort: 3000
              # targetPort: 4181 To be used with a proxy extraContainer
              annotations: {}
              labels: {}
              portName: service

            ingress:
              ## If true, Grafana Ingress will be created
              ##
              enabled: true

              ## Annotations for Grafana Ingress
              ##
              annotations: {}
              # kubernetes.io/ingress.class: nginx
              # kubernetes.io/tls-acme: "true"

              ## Labels to be added to the Ingress
              ##
              labels: {}

              ## Hostnames.
              ## Must be provided if Ingress is enable.
              ##
              # hosts:
              #   - grafana.domain.com
              hosts:
                - monitoring.cluster1.discovery.spectrocloud.com

              ## Path for grafana ingress
              path: /

              ## TLS configuration for grafana Ingress
              ## Secret must be manually created in the namespace
              ##
              tls: []
              # - secretName: grafana-general-tls
              #   hosts:
              #   - grafana.example.com

            sidecar:
              dashboards:
                enabled: true
                label: grafana_dashboard
              datasources:
                enabled: true
                defaultDatasourceEnabled: true

                ## Annotations for Grafana datasource configmaps
                ##
                annotations: {}

                ## Create datasource for each Pod of Prometheus StatefulSet;
                ## this uses headless service `prometheus-operated` which is
                ## created by Prometheus Operator
                ## ref: https://git.io/fjaBS
                createPrometheusReplicasDatasources: false
                label: grafana_datasource

            extraConfigmapMounts: []
            # - name: certs-configmap
            #   mountPath: /etc/grafana/ssl/
            #   configMap: certs-configmap
            #   readOnly: true

            ## Configure additional grafana datasources
            ## ref: http://docs.grafana.org/administration/provisioning/#datasources
            additionalDataSources: []
            # - name: prometheus-sample
            #   access: proxy
            #   basicAuth: true
            #   basicAuthPassword: pass
            #   basicAuthUser: daco
            #   editable: false
            #   jsonData:
            #       tlsSkipVerify: true
            #   orgId: 1
            #   type: prometheus
            #   url: https://prometheus.svc:9090
            #   version: 1

            ## If true, create a serviceMonitor for grafana
            ##
            serviceMonitor:
              ## Scrape interval. If not set, the Prometheus default scrape interval is used.
              ##
              interval: ""
              selfMonitor: true

              ## 	metric relabel configs to apply to samples before ingestion.
              ##
              metricRelabelings: []
              # - action: keep
              #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
              #   sourceLabels: [__name__]

              # 	relabel configs to apply to samples before ingestion.
              ##
              relabelings: []
              # - sourceLabels: [__meta_kubernetes_pod_node_name]
              #   separator: ;
              #   regex: ^(.*)$
              #   targetLabel: nodename
              #   replacement: $1
              #   action: replace

          ## Component scraping the kube api server
          ##
          kubeApiServer:
            enabled: true
            tlsConfig:
              serverName: kubernetes
              insecureSkipVerify: false

            ## If your API endpoint address is not reachable (as in AKS) you can replace it with the kubernetes service
            ##
            relabelings: []
            # - sourceLabels:
            #     - __meta_kubernetes_namespace
            #     - __meta_kubernetes_service_name
            #     - __meta_kubernetes_endpoint_port_name
            #   action: keep
            #   regex: default;kubernetes;https
            # - targetLabel: __address__
            #   replacement: kubernetes.default.svc:443

            serviceMonitor:
              ## Scrape interval. If not set, the Prometheus default scrape interval is used.
              ##
              interval: ""
              jobLabel: component
              selector:
                matchLabels:
                  component: apiserver
                  provider: kubernetes

              ## 	metric relabel configs to apply to samples before ingestion.
              ##
              metricRelabelings: []
              # - action: keep
              #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
              #   sourceLabels: [__name__]

          ## Component scraping the kubelet and kubelet-hosted cAdvisor
          ##
          kubelet:
            enabled: true
            namespace: kube-system

            serviceMonitor:
              ## Scrape interval. If not set, the Prometheus default scrape interval is used.
              ##
              interval: ""

              ## Enable scraping the kubelet over https. For requirements to enable this see
              ## https://github.com/coreos/prometheus-operator/issues/926
              ##
              https: true

              ## Metric relabellings to apply to samples before ingestion
              ##
              cAdvisorMetricRelabelings: []
              # - sourceLabels: [__name__, image]
              #   separator: ;
              #   regex: container_([a-z_]+);
              #   replacement: $1
              #   action: drop
              # - sourceLabels: [__name__]
              #   separator: ;
              #   regex: container_(network_tcp_usage_total|network_udp_usage_total|tasks_state|cpu_load_average_10s)
              #   replacement: $1
              #   action: drop

              # 	relabel configs to apply to samples before ingestion.
              ##
              cAdvisorRelabelings: []
              # - sourceLabels: [__meta_kubernetes_pod_node_name]
              #   separator: ;
              #   regex: ^(.*)$
              #   targetLabel: nodename
              #   replacement: $1
              #   action: replace

              metricRelabelings: []
              # - sourceLabels: [__name__, image]
              #   separator: ;
              #   regex: container_([a-z_]+);
              #   replacement: $1
              #   action: drop
              # - sourceLabels: [__name__]
              #   separator: ;
              #   regex: container_(network_tcp_usage_total|network_udp_usage_total|tasks_state|cpu_load_average_10s)
              #   replacement: $1
              #   action: drop

              # 	relabel configs to apply to samples before ingestion.
              ##
              relabelings: []
              # - sourceLabels: [__meta_kubernetes_pod_node_name]
              #   separator: ;
              #   regex: ^(.*)$
              #   targetLabel: nodename
              #   replacement: $1
              #   action: replace

          ## Component scraping the kube controller manager
          ##
          kubeControllerManager:
            enabled: true

            ## If your kube controller manager is not deployed as a pod, specify IPs it can be found on
            ##
            endpoints: []
            # - 10.141.4.22
            # - 10.141.4.23
            # - 10.141.4.24

            ## If using kubeControllerManager.endpoints only the port and targetPort are used
            ##
            service:
              port: 10252
              targetPort: 10252
              # selector:
              #   component: kube-controller-manager

            serviceMonitor:
              ## Scrape interval. If not set, the Prometheus default scrape interval is used.
              ##
              interval: ""

              ## Enable scraping kube-controller-manager over https.
              ## Requires proper certs (not self-signed) and delegated authentication/authorization checks
              ##
              https: false

              # Skip TLS certificate validation when scraping
              insecureSkipVerify: null

              # Name of the server to use when validating TLS certificate
              serverName: null

              ## 	metric relabel configs to apply to samples before ingestion.
              ##
              metricRelabelings: []
              # - action: keep
              #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
              #   sourceLabels: [__name__]

              # 	relabel configs to apply to samples before ingestion.
              ##
              relabelings: []
              # - sourceLabels: [__meta_kubernetes_pod_node_name]
              #   separator: ;
              #   regex: ^(.*)$
              #   targetLabel: nodename
              #   replacement: $1
              #   action: replace

          ## Component scraping coreDns. Use either this or kubeDns
          ##
          coreDns:
            enabled: true
            service:
              port: 9153
              targetPort: 9153
              # selector:
              #   k8s-app: kube-dns
            serviceMonitor:
              ## Scrape interval. If not set, the Prometheus default scrape interval is used.
              ##
              interval: ""

              ## 	metric relabel configs to apply to samples before ingestion.
              ##
              metricRelabelings: []
              # - action: keep
              #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
              #   sourceLabels: [__name__]

              # 	relabel configs to apply to samples before ingestion.
              ##
              relabelings: []
              # - sourceLabels: [__meta_kubernetes_pod_node_name]
              #   separator: ;
              #   regex: ^(.*)$
              #   targetLabel: nodename
              #   replacement: $1
              #   action: replace

          ## Component scraping kubeDns. Use either this or coreDns
          ##
          kubeDns:
            enabled: false
            service:
              dnsmasq:
                port: 10054
                targetPort: 10054
              skydns:
                port: 10055
                targetPort: 10055
              # selector:
              #   k8s-app: kube-dns
            serviceMonitor:
              ## Scrape interval. If not set, the Prometheus default scrape interval is used.
              ##
              interval: ""

              ## 	metric relabel configs to apply to samples before ingestion.
              ##
              metricRelabelings: []
              # - action: keep
              #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
              #   sourceLabels: [__name__]

              # 	relabel configs to apply to samples before ingestion.
              ##
              relabelings: []
              # - sourceLabels: [__meta_kubernetes_pod_node_name]
              #   separator: ;
              #   regex: ^(.*)$
              #   targetLabel: nodename
              #   replacement: $1
              #   action: replace
              dnsmasqMetricRelabelings: []
              # - action: keep
              #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
              #   sourceLabels: [__name__]

              # 	relabel configs to apply to samples before ingestion.
              ##
              dnsmasqRelabelings: []
              # - sourceLabels: [__meta_kubernetes_pod_node_name]
              #   separator: ;
              #   regex: ^(.*)$
              #   targetLabel: nodename
              #   replacement: $1
              #   action: replace

          ## Component scraping etcd
          ##
          kubeEtcd:
            enabled: true

            ## If your etcd is not deployed as a pod, specify IPs it can be found on
            ##
            endpoints: []
            # - 10.141.4.22
            # - 10.141.4.23
            # - 10.141.4.24

            ## Etcd service. If using kubeEtcd.endpoints only the port and targetPort are used
            ##
            service:
              port: 2379
              targetPort: 2379
              # selector:
              #   component: etcd

            ## Configure secure access to the etcd cluster by loading a secret into prometheus and
            ## specifying security configuration below. For example, with a secret named etcd-client-cert
            ##
            ## serviceMonitor:
            ##   scheme: https
            ##   insecureSkipVerify: false
            ##   serverName: localhost
            ##   caFile: /etc/prometheus/secrets/etcd-client-cert/etcd-ca
            ##   certFile: /etc/prometheus/secrets/etcd-client-cert/etcd-client
            ##   keyFile: /etc/prometheus/secrets/etcd-client-cert/etcd-client-key
            ##
            serviceMonitor:
              ## Scrape interval. If not set, the Prometheus default scrape interval is used.
              ##
              interval: ""
              scheme: http
              insecureSkipVerify: false
              serverName: ""
              caFile: ""
              certFile: ""
              keyFile: ""

              ## 	metric relabel configs to apply to samples before ingestion.
              ##
              metricRelabelings: []
              # - action: keep
              #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
              #   sourceLabels: [__name__]

              # 	relabel configs to apply to samples before ingestion.
              ##
              relabelings: []
              # - sourceLabels: [__meta_kubernetes_pod_node_name]
              #   separator: ;
              #   regex: ^(.*)$
              #   targetLabel: nodename
              #   replacement: $1
              #   action: replace


          ## Component scraping kube scheduler
          ##
          kubeScheduler:
            enabled: true

            ## If your kube scheduler is not deployed as a pod, specify IPs it can be found on
            ##
            endpoints: []
            # - 10.141.4.22
            # - 10.141.4.23
            # - 10.141.4.24

            ## If using kubeScheduler.endpoints only the port and targetPort are used
            ##
            service:
              port: 10251
              targetPort: 10251
              # selector:
              #   component: kube-scheduler

            serviceMonitor:
              ## Scrape interval. If not set, the Prometheus default scrape interval is used.
              ##
              interval: ""
              ## Enable scraping kube-controller-manager over https.
              ## Requires proper certs (not self-signed) and delegated authentication/authorization checks
              ##
              https: false

              ## Skip TLS certificate validation when scraping
              insecureSkipVerify: null

              ## Name of the server to use when validating TLS certificate
              serverName: null

              ## 	metric relabel configs to apply to samples before ingestion.
              ##
              metricRelabelings: []
              # - action: keep
              #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
              #   sourceLabels: [__name__]

              # 	relabel configs to apply to samples before ingestion.
              ##
              relabelings: []
              # - sourceLabels: [__meta_kubernetes_pod_node_name]
              #   separator: ;
              #   regex: ^(.*)$
              #   targetLabel: nodename
              #   replacement: $1
              #   action: replace


          ## Component scraping kube proxy
          ##
          kubeProxy:
            enabled: true

            ## If your kube proxy is not deployed as a pod, specify IPs it can be found on
            ##
            endpoints: []
            # - 10.141.4.22
            # - 10.141.4.23
            # - 10.141.4.24

            service:
              port: 10249
              targetPort: 10249
              # selector:
              #   k8s-app: kube-proxy

            serviceMonitor:
              ## Scrape interval. If not set, the Prometheus default scrape interval is used.
              ##
              interval: ""

              ## Enable scraping kube-proxy over https.
              ## Requires proper certs (not self-signed) and delegated authentication/authorization checks
              ##
              https: false

              ## 	metric relabel configs to apply to samples before ingestion.
              ##
              metricRelabelings: []
              # - action: keep
              #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
              #   sourceLabels: [__name__]

              # 	relabel configs to apply to samples before ingestion.
              ##
              relabelings: []
              # - action: keep
              #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
              #   sourceLabels: [__name__]


          ## Component scraping kube state metrics
          ##
          kubeStateMetrics:
            enabled: true
            serviceMonitor:
              ## Scrape interval. If not set, the Prometheus default scrape interval is used.
              ##
              interval: ""

              ## 	metric relabel configs to apply to samples before ingestion.
              ##
              metricRelabelings: []
              # - action: keep
              #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
              #   sourceLabels: [__name__]

              # 	relabel configs to apply to samples before ingestion.
              ##
              relabelings: []
              # - sourceLabels: [__meta_kubernetes_pod_node_name]
              #   separator: ;
              #   regex: ^(.*)$
              #   targetLabel: nodename
              #   replacement: $1
              #   action: replace

          ## Configuration for kube-state-metrics subchart
          ##
          kube-state-metrics:
            fullnameOverride: "kube-state-metrics"
            rbac:
              create: true
            podSecurityPolicy:
              enabled: true

          ## Deploy node exporter as a daemonset to all nodes
          ##
          nodeExporter:
            enabled: true

            ## Use the value configured in prometheus-node-exporter.podLabels
            ##
            jobLabel: jobLabel

            serviceMonitor:
              ## Scrape interval. If not set, the Prometheus default scrape interval is used.
              ##
              interval: ""

              ## How long until a scrape request times out. If not set, the Prometheus default scape timeout is used.
              ##
              scrapeTimeout: ""

              ## 	metric relabel configs to apply to samples before ingestion.
              ##
              metricRelabelings: []
              # - sourceLabels: [__name__]
              #   separator: ;
              #   regex: ^node_mountstats_nfs_(event|operations|transport)_.+
              #   replacement: $1
              #   action: drop

              ## 	relabel configs to apply to samples before ingestion.
              ##
              relabelings: []
              # - sourceLabels: [__meta_kubernetes_pod_node_name]
              #   separator: ;
              #   regex: ^(.*)$
              #   targetLabel: nodename
              #   replacement: $1
              #   action: replace

          ## Configuration for prometheus-node-exporter subchart
          ##
          prometheus-node-exporter:
            fullnameOverride: "prometheus-node-exporter"
            podLabels:
              ## Add the 'node-exporter' label to be used by serviceMonitor to match standard common usage in rules and grafana dashboards
              ##
              jobLabel: node-exporter
            extraArgs:
              - --collector.filesystem.ignored-mount-points=^/(dev|proc|sys|var/lib/docker/.+)($|/)
              - --collector.filesystem.ignored-fs-types=^(autofs|binfmt_misc|cgroup|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|mqueue|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|sysfs|tracefs)$

          ## Manages Prometheus and Alertmanager components
          ##
          prometheusOperator:
            enabled: true

            tlsProxy:
              enabled: true
              image:
                repository: squareup/ghostunnel
                tag: v1.4.1
                pullPolicy: IfNotPresent
              resources: {}

            ## Admission webhook support for PrometheusRules resources added in Prometheus Operator 0.30 can be enabled to prevent incorrectly formatted
            ## rules from making their way into prometheus and potentially preventing the container from starting
            admissionWebhooks:
              failurePolicy: Fail
              enabled: true
              ## If enabled, generate a self-signed certificate, then patch the webhook configurations with the generated data.
              ## On chart upgrades (or if the secret exists) the cert will not be re-generated. You can use this to provide your own
              ## certs ahead of time if you wish.
              ##
              patch:
                enabled: true
                image:
                  repository: jettech/kube-webhook-certgen
                  tag: v1.0.0
                  pullPolicy: IfNotPresent
                resources: {}
                ## Provide a priority class name to the webhook patching job
                ##
                priorityClassName: ""
                podAnnotations: {}
                nodeSelector: {}

            ## Namespaces to scope the interaction of the Prometheus Operator and the apiserver (allow list).
            ## This is mutually exclusive with denyNamespaces. Setting this to an empty object will disable the configuration
            ##
            namespaces: {}
              # releaseNamespace: true
            # additional:
            # - kube-system

            ## Namespaces not to scope the interaction of the Prometheus Operator (deny list).
            ##
            denyNamespaces: []

            ## Service account for Alertmanager to use.
            ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
            ##
            serviceAccount:
              create: true
              name: ""

            ## Configuration for Prometheus operator service
            ##
            service:
              annotations: {}
              labels: {}
              clusterIP: ""

              ## Port to expose on each node
              ## Only used if service.type is 'NodePort'
              ##
              nodePort: 30080

              nodePortTls: 30443

              ## Additional ports to open for Prometheus service
              ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#multi-port-services
              ##
              additionalPorts: []

              ## Loadbalancer IP
              ## Only use if service.type is "loadbalancer"
              ##
              loadBalancerIP: ""
              loadBalancerSourceRanges: []

              ## Service type
              ## NodepPort, ClusterIP, loadbalancer
              ##
              type: ClusterIP

              ## List of IP addresses at which the Prometheus server service is available
              ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
              ##
              externalIPs: []

            ## Deploy CRDs used by Prometheus Operator.
            ##
            createCustomResource: false

            ## Attempt to clean up CRDs created by Prometheus Operator.
            ##
            cleanupCustomResource: false

            ## Labels to add to the operator pod
            ##
            podLabels: {}

            ## Annotations to add to the operator pod
            ##
            podAnnotations: {}

            ## Assign a PriorityClassName to pods if set
            # priorityClassName: ""

            ## Define Log Format
            # Use logfmt (default) or json-formatted logging
            # logFormat: logfmt

            ## Decrease log verbosity to errors only
            # logLevel: error

            ## If true, the operator will create and maintain a service for scraping kubelets
            ## ref: https://github.com/coreos/prometheus-operator/blob/master/helm/prometheus-operator/README.md
            ##
            kubeletService:
              enabled: true
              namespace: kube-system

            ## Create a servicemonitor for the operator
            ##
            serviceMonitor:
              ## Scrape interval. If not set, the Prometheus default scrape interval is used.
              ##
              interval: ""
              selfMonitor: true

              ## 	metric relabel configs to apply to samples before ingestion.
              ##
              metricRelabelings: []
              # - action: keep
              #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
              #   sourceLabels: [__name__]

              # 	relabel configs to apply to samples before ingestion.
              ##
              relabelings: []
              # - sourceLabels: [__meta_kubernetes_pod_node_name]
              #   separator: ;
              #   regex: ^(.*)$
              #   targetLabel: nodename
              #   replacement: $1
              #   action: replace

            ## Resource limits & requests
            ##
            resources: {}
            # limits:
            #   cpu: 200m
            #   memory: 200Mi
            # requests:
            #   cpu: 100m
            #   memory: 100Mi

            ## Define which Nodes the Pods are scheduled on.
            ## ref: https://kubernetes.io/docs/user-guide/node-selection/
            ##
            nodeSelector: {}

            ## Tolerations for use with node taints
            ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
            ##
            tolerations: []
            # - key: "key"
            #   operator: "Equal"
            #   value: "value"
            #   effect: "NoSchedule"

            ## Assign custom affinity rules to the prometheus operator
            ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
            ##
            affinity: {}
              # nodeAffinity:
              #   requiredDuringSchedulingIgnoredDuringExecution:
              #     nodeSelectorTerms:
              #     - matchExpressions:
              #       - key: kubernetes.io/e2e-az-name
              #         operator: In
              #         values:
            #         - e2e-az1
            #         - e2e-az2

            securityContext:
              runAsNonRoot: true
              runAsUser: 65534

            ## Prometheus-operator image
            ##
            image:
              repository: quay.io/coreos/prometheus-operator
              tag: v0.34.0
              pullPolicy: IfNotPresent

            ## Configmap-reload image to use for reloading configmaps
            ##
            configmapReloadImage:
              repository: quay.io/coreos/configmap-reload
              tag: v0.0.1

            ## Prometheus-config-reloader image to use for config and rule reloading
            ##
            prometheusConfigReloaderImage:
              repository: quay.io/coreos/prometheus-config-reloader
              tag: v0.34.0

            ## Set the prometheus config reloader side-car CPU limit
            ##
            configReloaderCpu: 100m

            ## Set the prometheus config reloader side-car memory limit
            ##
            configReloaderMemory: 25Mi

            ## Hyperkube image to use when cleaning up
            ##
            hyperkubeImage:
              repository: k8s.gcr.io/hyperkube
              tag: v1.12.1
              pullPolicy: IfNotPresent

          ## Deploy a Prometheus instance
          ##
          prometheus:

            enabled: true

            ## Annotations for Prometheus
            ##
            annotations: {}

            ## Service account for Prometheuses to use.
            ## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
            ##
            serviceAccount:
              create: true
              name: ""

            ## Configuration for Prometheus service
            ##
            service:
              annotations: {}
              labels: {}
              clusterIP: ""

              ## Port for Prometheus Service to listen on
              ##
              port: 9090

              ## To be used with a proxy extraContainer port
              targetPort: 9090

              ## List of IP addresses at which the Prometheus server service is available
              ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
              ##
              externalIPs: []

              ## Port to expose on each node
              ## Only used if service.type is 'NodePort'
              ##
              nodePort: 30090

              ## Loadbalancer IP
              ## Only use if service.type is "loadbalancer"
              loadBalancerIP: ""
              loadBalancerSourceRanges: []
              ## Service type
              ##
              type: ClusterIP

              sessionAffinity: ""

            ## Configuration for creating a separate Service for each statefulset Prometheus replica
            ##
            servicePerReplica:
              enabled: false
              annotations: {}

              ## Port for Prometheus Service per replica to listen on
              ##
              port: 9090

              ## To be used with a proxy extraContainer port
              targetPort: 9090

              ## Port to expose on each node
              ## Only used if servicePerReplica.type is 'NodePort'
              ##
              nodePort: 30091

              ## Loadbalancer source IP ranges
              ## Only used if servicePerReplica.type is "loadbalancer"
              loadBalancerSourceRanges: []
              ## Service type
              ##
              type: ClusterIP

            ## Configure pod disruption budgets for Prometheus
            ## ref: https://kubernetes.io/docs/tasks/run-application/configure-pdb/#specifying-a-poddisruptionbudget
            ## This configuration is immutable once created and will require the PDB to be deleted to be changed
            ## https://github.com/kubernetes/kubernetes/issues/45398
            ##
            podDisruptionBudget:
              enabled: false
              minAvailable: 1
              maxUnavailable: ""

            ingress:
              enabled: false
              annotations: {}
              labels: {}

              ## Hostnames.
              ## Must be provided if Ingress is enabled.
              ##
              # hosts:
              #   - prometheus.domain.com
              hosts: []

              ## Paths to use for ingress rules - one path should match the prometheusSpec.routePrefix
              ##
              paths: []
              # - /

              ## TLS configuration for Prometheus Ingress
              ## Secret must be manually created in the namespace
              ##
              tls: []
                # - secretName: prometheus-general-tls
              #   hosts:
              #     - prometheus.example.com

            ## Configuration for creating an Ingress that will map to each Prometheus replica service
            ## prometheus.servicePerReplica must be enabled
            ##
            ingressPerReplica:
              enabled: false
              annotations: {}
              labels: {}

              ## Final form of the hostname for each per replica ingress is
              ## {{ ingressPerReplica.hostPrefix }}-{{ $replicaNumber }}.{{ ingressPerReplica.hostDomain }}
              ##
              ## Prefix for the per replica ingress that will have `-$replicaNumber`
              ## appended to the end
              hostPrefix: ""
              ## Domain that will be used for the per replica ingress
              hostDomain: ""

              ## Paths to use for ingress rules
              ##
              paths: []
              # - /

              ## Secret name containing the TLS certificate for Prometheus per replica ingress
              ## Secret must be manually created in the namespace
              tlsSecretName: ""

            ## Configure additional options for default pod security policy for Prometheus
            ## ref: https://kubernetes.io/docs/concepts/policy/pod-security-policy/
            podSecurityPolicy:
              allowedCapabilities: []

            serviceMonitor:
              ## Scrape interval. If not set, the Prometheus default scrape interval is used.
              ##
              interval: ""
              selfMonitor: true

              bearerTokenFile:

              ## 	metric relabel configs to apply to samples before ingestion.
              ##
              metricRelabelings: []
              # - action: keep
              #   regex: 'kube_(daemonset|deployment|pod|namespace|node|statefulset).+'
              #   sourceLabels: [__name__]

              # 	relabel configs to apply to samples before ingestion.
              ##
              relabelings: []
              # - sourceLabels: [__meta_kubernetes_pod_node_name]
              #   separator: ;
              #   regex: ^(.*)$
              #   targetLabel: nodename
              #   replacement: $1
              #   action: replace

            ## Settings affecting prometheusSpec
            ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#prometheusspec
            ##
            prometheusSpec:

              ## Interval between consecutive scrapes.
              ##
              scrapeInterval: ""

              ## Interval between consecutive evaluations.
              ##
              evaluationInterval: ""

              ## ListenLocal makes the Prometheus server listen on loopback, so that it does not bind against the Pod IP.
              ##
              listenLocal: false

              ## EnableAdminAPI enables Prometheus the administrative HTTP API which includes functionality such as deleting time series.
              ## This is disabled by default.
              ## ref: https://prometheus.io/docs/prometheus/latest/querying/api/#tsdb-admin-apis
              ##
              enableAdminAPI: false

              ## Image of Prometheus.
              ##
              image:
                repository: quay.io/prometheus/prometheus
                tag: v2.13.1

              ## Tolerations for use with node taints
              ## ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
              ##
              tolerations: []
              #  - key: "key"
              #    operator: "Equal"
              #    value: "value"
              #    effect: "NoSchedule"

              ## Alertmanagers to which alerts will be sent
              ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#alertmanagerendpoints
              ##
              ## Default configuration will connect to the alertmanager deployed as part of this release
              ##
              alertingEndpoints: []
              # - name: ""
              #   namespace: ""
              #   port: http
              #   scheme: http

              ## External labels to add to any time series or alerts when communicating with external systems
              ##
              externalLabels: {}

              ## Name of the external label used to denote replica name
              ##
              replicaExternalLabelName: ""

              ## If true, the Operator won't add the external label used to denote replica name
              ##
              replicaExternalLabelNameClear: false

              ## Name of the external label used to denote Prometheus instance name
              ##
              prometheusExternalLabelName: ""

              ## If true, the Operator won't add the external label used to denote Prometheus instance name
              ##
              prometheusExternalLabelNameClear: false

              ## External URL at which Prometheus will be reachable.
              ##
              externalUrl: ""

              ## Define which Nodes the Pods are scheduled on.
              ## ref: https://kubernetes.io/docs/user-guide/node-selection/
              ##
              nodeSelector: {}

              ## Secrets is a list of Secrets in the same namespace as the Prometheus object, which shall be mounted into the Prometheus Pods.
              ## The Secrets are mounted into /etc/prometheus/secrets/. Secrets changes after initial creation of a Prometheus object are not
              ## reflected in the running Pods. To change the secrets mounted into the Prometheus Pods, the object must be deleted and recreated
              ## with the new list of secrets.
              ##
              secrets: []

              ## ConfigMaps is a list of ConfigMaps in the same namespace as the Prometheus object, which shall be mounted into the Prometheus Pods.
              ## The ConfigMaps are mounted into /etc/prometheus/configmaps/.
              ##
              configMaps: []

              ## QuerySpec defines the query command line flags when starting Prometheus.
              ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#queryspec
              ##
              query: {}

              ## Namespaces to be selected for PrometheusRules discovery.
              ## If nil, select own namespace. Namespaces to be selected for ServiceMonitor discovery.
              ## See https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#namespaceselector for usage
              ##
              ruleNamespaceSelector:
                any: true

              ## If true, a nil or {} value for prometheus.prometheusSpec.ruleSelector will cause the
              ## prometheus resource to be created with selectors based on values in the helm deployment,
              ## which will also match the PrometheusRule resources created
              ##
              ruleSelectorNilUsesHelmValues: false

              ## PrometheusRules to be selected for target discovery.
              ## If {}, select all ServiceMonitors
              ##
              ruleSelector: {}
              ## Example which select all prometheusrules resources
              ## with label "prometheus" with values any of "example-rules" or "example-rules-2"
              # ruleSelector:
              #   matchExpressions:
              #     - key: prometheus
              #       operator: In
              #       values:
              #         - example-rules
              #         - example-rules-2
              #
              ## Example which select all prometheusrules resources with label "role" set to "example-rules"
              # ruleSelector:
              #   matchLabels:
              #     role: example-rules

              ## If true, a nil or {} value for prometheus.prometheusSpec.serviceMonitorSelector will cause the
              ## prometheus resource to be created with selectors based on values in the helm deployment,
              ## which will also match the servicemonitors created
              ##
              serviceMonitorSelectorNilUsesHelmValues: false

              ## ServiceMonitors to be selected for target discovery.
              ## If {}, select all ServiceMonitors
              ##
              serviceMonitorSelector: {}
              ## Example which selects ServiceMonitors with label "prometheus" set to "somelabel"
              # serviceMonitorSelector:
              #   matchLabels:
              #     prometheus: somelabel

              ## Namespaces to be selected for ServiceMonitor discovery.
              ## See https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#namespaceselector for usage
              ##
              serviceMonitorNamespaceSelector:
                any: true

              ## If true, a nil or {} value for prometheus.prometheusSpec.podMonitorSelector will cause the
              ## prometheus resource to be created with selectors based on values in the helm deployment,
              ## which will also match the podmonitors created
              ##
              podMonitorSelectorNilUsesHelmValues: false

              ## PodMonitors to be selected for target discovery.
              ## If {}, select all PodMonitors
              ##
              podMonitorSelector: {}
              ## Example which selects PodMonitors with label "prometheus" set to "somelabel"
              # podMonitorSelector:
              #   matchLabels:
              #     prometheus: somelabel

              ## Namespaces to be selected for PodMonitor discovery.
              ## See https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#namespaceselector for usage
              ##
              podMonitorNamespaceSelector:
                any: true

              ## How long to retain metrics
              ##
              retention: 30d

              ## Maximum size of metrics
              ##
              retentionSize: "20GB"

              ## Enable compression of the write-ahead log using Snappy.
              ##
              walCompression: false

              ## If true, the Operator won't process any Prometheus configuration changes
              ##
              paused: false

              ## Number of Prometheus replicas desired
              ##
              replicas: 1

              ## Log level for Prometheus be configured in
              ##
              logLevel: info

              ## Log format for Prometheus be configured in
              ##
              logFormat: logfmt

              ## Prefix used to register routes, overriding externalUrl route.
              ## Useful for proxies that rewrite URLs.
              ##
              routePrefix: /

              ## Standard object’s metadata. More info: https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#metadata
              ## Metadata Labels and Annotations gets propagated to the prometheus pods.
              ##
              podMetadata: {}
              # labels:
              #   app: prometheus
              #   k8s-app: prometheus

              ## Pod anti-affinity can prevent the scheduler from placing Prometheus replicas on the same node.
              ## The default value "soft" means that the scheduler should *prefer* to not schedule two replica pods onto the same node but no guarantee is provided.
              ## The value "hard" means that the scheduler is *required* to not schedule two replica pods onto the same node.
              ## The value "" will disable pod anti-affinity so that no anti-affinity rules will be configured.
              podAntiAffinity: ""

              ## If anti-affinity is enabled sets the topologyKey to use for anti-affinity.
              ## This can be changed to, for example, failure-domain.beta.kubernetes.io/zone
              ##
              podAntiAffinityTopologyKey: kubernetes.io/hostname

              ## Assign custom affinity rules to the prometheus instance
              ## ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
              ##
              affinity: {}
              # nodeAffinity:
              #   requiredDuringSchedulingIgnoredDuringExecution:
              #     nodeSelectorTerms:
              #     - matchExpressions:
              #       - key: kubernetes.io/e2e-az-name
              #         operator: In
              #         values:
              #         - e2e-az1
              #         - e2e-az2

              ## The remote_read spec configuration for Prometheus.
              ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#remotereadspec
              remoteRead: []
              # - url: http://remote1/read

              ## The remote_write spec configuration for Prometheus.
              ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#remotewritespec
              remoteWrite: []
              # - url: http://remote1/push

              ## Enable/Disable Grafana dashboards provisioning for prometheus remote write feature
              remoteWriteDashboards: false

              ## Resource limits & requests
              ##
              resources: {}
              # requests:
              #   memory: 400Mi

              ## Prometheus StorageSpec for persistent data
              ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/user-guides/storage.md
              ##
              storageSpec:
                volumeClaimTemplate:
                  spec:
                    storageClassName: spectro-storage-class
                    accessModes: ["ReadWriteOnce"]
                    resources:
                      requests:
                        storage: 50Gi
                  selector: {}

              ## AdditionalScrapeConfigs allows specifying additional Prometheus scrape configurations. Scrape configurations
              ## are appended to the configurations generated by the Prometheus Operator. Job configurations must have the form
              ## as specified in the official Prometheus documentation:
              ## https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config. As scrape configs are
              ## appended, the user is responsible to make sure it is valid. Note that using this feature may expose the possibility
              ## to break upgrades of Prometheus. It is advised to review Prometheus release notes to ensure that no incompatible
              ## scrape configs are going to break Prometheus after the upgrade.
              ##
              ## The scrape configuraiton example below will find master nodes, provided they have the name .*mst.*, relabel the
              ## port to 2379 and allow etcd scraping provided it is running on all Kubernetes master nodes
              ##
              additionalScrapeConfigs: []
              # - job_name: kube-etcd
              #   kubernetes_sd_configs:
              #     - role: node
              #   scheme: https
              #   tls_config:
              #     ca_file:   /etc/prometheus/secrets/etcd-client-cert/etcd-ca
              #     cert_file: /etc/prometheus/secrets/etcd-client-cert/etcd-client
              #     key_file:  /etc/prometheus/secrets/etcd-client-cert/etcd-client-key
              #   relabel_configs:
              #   - action: labelmap
              #     regex: __meta_kubernetes_node_label_(.+)
              #   - source_labels: [__address__]
              #     action: replace
              #     targetLabel: __address__
              #     regex: ([^:;]+):(\d+)
              #     replacement: ${1}:2379
              #   - source_labels: [__meta_kubernetes_node_name]
              #     action: keep
              #     regex: .*mst.*
              #   - source_labels: [__meta_kubernetes_node_name]
              #     action: replace
              #     targetLabel: node
              #     regex: (.*)
              #     replacement: ${1}
              #   metric_relabel_configs:
              #   - regex: (kubernetes_io_hostname|failure_domain_beta_kubernetes_io_region|beta_kubernetes_io_os|beta_kubernetes_io_arch|beta_kubernetes_io_instance_type|failure_domain_beta_kubernetes_io_zone)
              #     action: labeldrop


              ## AdditionalAlertManagerConfigs allows for manual configuration of alertmanager jobs in the form as specified
              ## in the official Prometheus documentation https://prometheus.io/docs/prometheus/latest/configuration/configuration/#<alertmanager_config>.
              ## AlertManager configurations specified are appended to the configurations generated by the Prometheus Operator.
              ## As AlertManager configs are appended, the user is responsible to make sure it is valid. Note that using this
              ## feature may expose the possibility to break upgrades of Prometheus. It is advised to review Prometheus release
              ## notes to ensure that no incompatible AlertManager configs are going to break Prometheus after the upgrade.
              ##
              additionalAlertManagerConfigs: []
              # - consul_sd_configs:
              #   - server: consul.dev.test:8500
              #     scheme: http
              #     datacenter: dev
              #     tag_separator: ','
              #     services:
              #       - metrics-prometheus-alertmanager

              ## AdditionalAlertRelabelConfigs allows specifying Prometheus alert relabel configurations. Alert relabel configurations specified are appended
              ## to the configurations generated by the Prometheus Operator. Alert relabel configurations specified must have the form as specified in the
              ## official Prometheus documentation: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#alert_relabel_configs.
              ## As alert relabel configs are appended, the user is responsible to make sure it is valid. Note that using this feature may expose the
              ## possibility to break upgrades of Prometheus. It is advised to review Prometheus release notes to ensure that no incompatible alert relabel
              ## configs are going to break Prometheus after the upgrade.
              ##
              additionalAlertRelabelConfigs: []
              # - separator: ;
              #   regex: prometheus_replica
              #   replacement: $1
              #   action: labeldrop

              ## SecurityContext holds pod-level security attributes and common container settings.
              ## This defaults to non root user with uid 1000 and gid 2000.
              ## https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md
              ##
              securityContext:
                runAsNonRoot: true
                runAsUser: 1000
                fsGroup: 2000

              ## 	Priority class assigned to the Pods
              ##
              priorityClassName: ""

              ## Thanos configuration allows configuring various aspects of a Prometheus server in a Thanos environment.
              ## This section is experimental, it may change significantly without deprecation notice in any release.
              ## This is experimental and may change significantly without backward compatibility in any release.
              ## ref: https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#thanosspec
              ##
              thanos: {}

              ## Containers allows injecting additional containers. This is meant to allow adding an authentication proxy to a Prometheus pod.
              ##  if using proxy extraContainer  update targetPort with proxy container port
              containers: []

              ## Enable additional scrape configs that are managed externally to this chart. Note that the prometheus
              ## will fail to provision if the correct secret does not exist.
              ## This option requires that you are maintaining a secret in the same namespace as Prometheus with
              ## a name of 'prometheus-operator-prometheus-scrape-confg' and a key of 'additional-scrape-configs.yaml' that
              ## contains a list of scrape_config's. The name of the secret may vary if you utilize the "fullnameOverride".
              ## This feature cannot be used in conjunction with the additionalScrapeConfigs attribute (the helm-generated
              ## secret will overwrite your self-maintained secret).
              ##
              ## scrape_config docs: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config
              ## explanation of "confg" typo: https://github.com/helm/charts/issues/13368
              additionalScrapeConfigsExternal: false

              ## PortName to use for Prometheus.
              ##
              portName: "web"

            additionalServiceMonitors: []
              ## Name of the ServiceMonitor to create
              ##
              # - name: ""

              ## Additional labels to set used for the ServiceMonitorSelector. Together with standard labels from
              ## the chart
              ##
              # additionalLabels: {}

              ## Service label for use in assembling a job name of the form <label value>-<port>
              ## If no label is specified, the service name is used.
              ##
              # jobLabel: ""

              ## labels to transfer from the kubernetes service to the target
              ##
              # targetLabels: ""

              ## Label selector for services to which this ServiceMonitor applies
              ##
              # selector: {}

              ## Namespaces from which services are selected
              ##
              # namespaceSelector:
              ## Match any namespace
              ##
              # any: false

              ## Explicit list of namespace names to select
              ##
              # matchNames: []

              ## Endpoints of the selected service to be monitored
              ##
              # endpoints: []
              ## Name of the endpoint's service port
              ## Mutually exclusive with targetPort
              # - port: ""

              ## Name or number of the endpoint's target port
              ## Mutually exclusive with port
              # - targetPort: ""

              ## File containing bearer token to be used when scraping targets
              ##
              #   bearerTokenFile: ""

              ## Interval at which metrics should be scraped
              ##
              #   interval: 30s

              ## HTTP path to scrape for metrics
              ##
              #   path: /metrics

              ## HTTP scheme to use for scraping
              ##
              #   scheme: http

              ## TLS configuration to use when scraping the endpoint
              ##
              #   tlsConfig:

              ## Path to the CA file
              ##
              # caFile: ""

              ## Path to client certificate file
              ##
              # certFile: ""

              ## Skip certificate verification
              ##
              # insecureSkipVerify: false

              ## Path to client key file
              ##
              # keyFile: ""

              ## Server name used to verify host name
            ##
            # serverName: ""

            additionalPodMonitors: []
              ## Name of the PodMonitor to create
              ##
              # - name: ""

              ## Additional labels to set used for the PodMonitorSelector. Together with standard labels from
              ## the chart
              ##
              # additionalLabels: {}

              ## Pod label for use in assembling a job name of the form <label value>-<port>
              ## If no label is specified, the pod endpoint name is used.
              ##
              # jobLabel: ""

              ## Label selector for pods to which this PodMonitor applies
              ##
              # selector: {}

              ## PodTargetLabels transfers labels on the Kubernetes Pod onto the target.
              ##
              # podTargetLabels: {}

              ## SampleLimit defines per-scrape limit on number of scraped samples that will be accepted.
              ##
              # sampleLimit: 0

              ## Namespaces from which pods are selected
              ##
              # namespaceSelector:
              ## Match any namespace
              ##
              # any: false

              ## Explicit list of namespace names to select
              ##
              # matchNames: []

              ## Endpoints of the selected pods to be monitored
              ## https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#podmetricsendpoint
            ##
            # podMetricsEndpoints: []
    EOT
  }

  pack {
    name   = "nginx"
    tag    = "0.26.x"
    uid    = data.spectrocloud_pack.nginx-vsphere.id
    values = <<-EOT
      pack:
        #The namespace (on the target cluster) to install this chart
        #When not found, a new namespace will be created
        namespace: "nginx"

      charts:
        nginx-ingress:
          fullnameOverride: "nginx-ingress"
          controller:
            fullnameOverride: nginx-ingress.controller
            name: controller
            image:
              repository: quay.io/kubernetes-ingress-controller/nginx-ingress-controller
              tag: "0.26.1"
              pullPolicy: IfNotPresent
              # www-data -> uid 33
              runAsUser: 33
              allowPrivilegeEscalation: true

            # Configures the ports the nginx-controller listens on
            containerPort:
              http: 80
              https: 443

            # Will add custom configuration options to Nginx https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
            config: {}

            # Will add custom headers before sending traffic to backends according to https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/customization/custom-headers
            proxySetHeaders: {}

            # Will add custom headers before sending response traffic to the client according to: https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#add-headers
            addHeaders: {}

            # Required for use with CNI based kubernetes installations (such as ones set up by kubeadm),
            # since CNI and hostport don't mix yet. Can be deprecated once https://github.com/kubernetes/kubernetes/issues/23920
            # is merged
            hostNetwork: true

            # Optionally change this to ClusterFirstWithHostNet in case you have 'hostNetwork: true'.
            # By default, while using host network, name resolution uses the host's DNS. If you wish nginx-controller
            # to keep resolving names inside the k8s network, use ClusterFirstWithHostNet.
            dnsPolicy: ClusterFirst

            # Bare-metal considerations via the host network https://kubernetes.github.io/ingress-nginx/deploy/baremetal/#via-the-host-network
            # Ingress status was blank because there is no Service exposing the NGINX Ingress controller in a configuration using the host network, the default --publish-service flag used in standard cloud setups does not apply
            reportNodeInternalIp: false

            ## Use host ports 80 and 443
            daemonset:
              useHostPort: false

              hostPorts:
                http: 80
                https: 443

            ## Required only if defaultBackend.enabled = false
            ## Must be <namespace>/<service_name>
            ##
            defaultBackendService: ""

            ## Election ID to use for status update
            ##
            electionID: ingress-controller-leader

            ## Name of the ingress class to route through this controller
            ##
            ingressClass: nginx

            # labels to add to the pod container metadata
            podLabels: {}
            #  key: value

            ## Security Context policies for controller pods
            ## See https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/ for
            ## notes on enabling and using sysctls
            ##
            podSecurityContext: {}

            ## Allows customization of the external service
            ## the ingress will be bound to via DNS
            publishService:
              enabled: true
              ## Allows overriding of the publish service to bind to
              ## Must be <namespace>/<service_name>
              ##
              pathOverride: ""

            ## Limit the scope of the controller
            ##
            scope:
              enabled: false
              namespace: ""   # defaults to .Release.Namespace

            ## Allows customization of the configmap / nginx-configmap namespace
            ##
            configMapNamespace: ""   # defaults to .Release.Namespace

            ## Allows customization of the tcp-services-configmap namespace
            ##
            tcp:
              configMapNamespace: ""   # defaults to .Release.Namespace

            ## Allows customization of the udp-services-configmap namespace
            ##
            udp:
              configMapNamespace: ""   # defaults to .Release.Namespace

            ## Additional command line arguments to pass to nginx-ingress-controller
            ## E.g. to specify the default SSL certificate you can use
            ## extraArgs:
            ##   default-ssl-certificate: "<namespace>/<secret_name>"
            extraArgs: {}

            ## Additional environment variables to set
            extraEnvs: []
            # extraEnvs:
            #   - name: FOO
            #     valueFrom:
            #       secretKeyRef:
            #         key: FOO
            #         name: secret-resource

            ## DaemonSet or Deployment
            ##
            kind: DaemonSet

            ## Annotations to be added to the controller deployment
            ##
            deploymentAnnotations: {}

            # The update strategy to apply to the Deployment or DaemonSet
            ##
            updateStrategy: {}
            #  rollingUpdate:
            #    maxUnavailable: 1
            #  type: RollingUpdate

            # minReadySeconds to avoid killing pods before we are ready
            ##
            minReadySeconds: 0


            ## Node tolerations for server scheduling to nodes with taints
            ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
            ##
            tolerations:
             - key: "node-role.kubernetes.io/master"
               effect: "NoSchedule"

            ## Affinity and anti-affinity
            ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
            ##
            affinity: {}
              # # An example of preferred pod anti-affinity, weight is in the range 1-100
              # podAntiAffinity:
              #   preferredDuringSchedulingIgnoredDuringExecution:
              #   - weight: 100
              #     podAffinityTerm:
              #       labelSelector:
              #         matchExpressions:
              #         - key: app
              #           operator: In
              #           values:
              #           - nginx-ingress
              #       topologyKey: kubernetes.io/hostname

              # # An example of required pod anti-affinity
              # podAntiAffinity:
              #   requiredDuringSchedulingIgnoredDuringExecution:
              #   - labelSelector:
              #       matchExpressions:
              #       - key: app
              #         operator: In
              #         values:
            #         - nginx-ingress
            #     topologyKey: "kubernetes.io/hostname"

            ## terminationGracePeriodSeconds
            ##
            terminationGracePeriodSeconds: 60

            ## Node labels for controller pod assignment
            ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
            ##
            nodeSelector:
              node-role.kubernetes.io/master: ""
            
            ## Liveness and readiness probe values
            ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
            ##
            livenessProbe:
              failureThreshold: 3
              initialDelaySeconds: 10
              periodSeconds: 10
              successThreshold: 1
              timeoutSeconds: 1
              port: 10254
            readinessProbe:
              failureThreshold: 3
              initialDelaySeconds: 10
              periodSeconds: 10
              successThreshold: 1
              timeoutSeconds: 1
              port: 10254

            ## Annotations to be added to controller pods
            ##
            podAnnotations: {}

            replicaCount: 1

            minAvailable: 1

            resources:
              limits:
                cpu: 500m
                memory: 500Mi
              requests:
                cpu: 100m
                memory: 64Mi

            autoscaling:
              enabled: true
              minReplicas: 1
              maxReplicas: 3
              targetCPUUtilizationPercentage: 70
              targetMemoryUtilizationPercentage: 80

            ## Override NGINX template
            customTemplate:
              configMapName: ""
              configMapKey: ""

            service:
              enabled: false

              annotations: {}
              labels: {}
              ## Deprecated, instead simply do not provide a clusterIP value
              omitClusterIP: false
              # clusterIP: ""

              ## List of IP addresses at which the controller services are available
              ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
              ##
              externalIPs: []

              loadBalancerIP: ""
              loadBalancerSourceRanges: []

              enableHttp: true
              enableHttps: true

              ## Set external traffic policy to: "Local" to preserve source IP on
              ## providers supporting it
              ## Ref: https://kubernetes.io/docs/tutorials/services/source-ip/#source-ip-for-services-with-typeloadbalancer
              externalTrafficPolicy: ""

              healthCheckNodePort: 0

              ports:
                http: 80
                https: 443

              targetPorts:
                http: http
                https: https

              type: LoadBalancer

              # type: NodePort
              # nodePorts:
              #   http: 32080
              #   https: 32443
              #   tcp:
              #     8080: 32808
              nodePorts:
                http: ""
                https: ""
                tcp: {}
                udp: {}

            extraContainers: []
            ## Additional containers to be added to the controller pod.
            ## See https://github.com/lemonldap-ng-controller/lemonldap-ng-controller as example.
            #  - name: my-sidecar
            #    image: nginx:latest
            #  - name: lemonldap-ng-controller
            #    image: lemonldapng/lemonldap-ng-controller:0.2.0
            #    args:
            #      - /lemonldap-ng-controller
            #      - --alsologtostderr
            #      - --configmap=$(POD_NAMESPACE)/lemonldap-ng-configuration
            #    env:
            #      - name: POD_NAME
            #        valueFrom:
            #          fieldRef:
            #            fieldPath: metadata.name
            #      - name: POD_NAMESPACE
            #        valueFrom:
            #          fieldRef:
            #            fieldPath: metadata.namespace
            #    volumeMounts:
            #    - name: copy-portal-skins
            #      mountPath: /srv/var/lib/lemonldap-ng/portal/skins

            extraVolumeMounts: []
            ## Additional volumeMounts to the controller main container.
            #  - name: copy-portal-skins
            #   mountPath: /var/lib/lemonldap-ng/portal/skins

            extraVolumes: []
            ## Additional volumes to the controller pod.
            #  - name: copy-portal-skins
            #    emptyDir: {}

            extraInitContainers: []
            ## Containers, which are run before the app containers are started.
            # - name: init-myservice
            #   image: busybox
            #   command: ['sh', '-c', 'until nslookup myservice; do echo waiting for myservice; sleep 2; done;']

            admissionWebhooks:
              enabled: false
              failurePolicy: Fail
              port: 8443

              service:
                annotations: {}
                ## Deprecated, instead simply do not provide a clusterIP value
                omitClusterIP: false
                # clusterIP: ""
                externalIPs: []
                loadBalancerIP: ""
                loadBalancerSourceRanges: []
                servicePort: 443
                type: ClusterIP

              patch:
                enabled: true
                image:
                  repository: jettech/kube-webhook-certgen
                  tag: v1.0.0
                  pullPolicy: IfNotPresent
                ## Provide a priority class name to the webhook patching job
                ##
                priorityClassName: ""
                podAnnotations: {}
                nodeSelector: {}

            metrics:
              port: 10254
              # if this port is changed, change healthz-port: in extraArgs: accordingly
              enabled: true

              service:
                annotations: {}
                # prometheus.io/scrape: "true"
                # prometheus.io/port: "10254"

                ## Deprecated, instead simply do not provide a clusterIP value
                omitClusterIP: false
                # clusterIP: ""

                ## List of IP addresses at which the stats-exporter service is available
                ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
                ##
                externalIPs: []

                loadBalancerIP: ""
                loadBalancerSourceRanges: []
                servicePort: 9913
                type: ClusterIP

              serviceMonitor:
                enabled: true
                additionalLabels: {}
                namespace: ""
                namespaceSelector: {}
                # Default: scrape .Release.Namespace only
                # To scrape all, use the following:
                # namespaceSelector:
                #   any: true
                scrapeInterval: 30s
                # honorLabels: true

              prometheusRule:
                enabled: false
                additionalLabels: {}
                namespace: ""
                rules: []
                  # # These are just examples rules, please adapt them to your needs
                  # - alert: TooMany500s
                  #   expr: 100 * ( sum( nginx_ingress_controller_requests{status=~"5.+"} ) / sum(nginx_ingress_controller_requests) ) > 5
                  #   for: 1m
                  #   labels:
                  #     severity: critical
                  #   annotations:
                  #     description: Too many 5XXs
                  #     summary: More than 5% of the all requests did return 5XX, this require your attention
                  # - alert: TooMany400s
                  #   expr: 100 * ( sum( nginx_ingress_controller_requests{status=~"4.+"} ) / sum(nginx_ingress_controller_requests) ) > 5
                  #   for: 1m
                  #   labels:
                  #     severity: critical
                  #   annotations:
                #     description: Too many 4XXs
                #     summary: More than 5% of the all requests did return 4XX, this require your attention


            lifecycle: {}

            priorityClassName: ""

          ## Rollback limit
          ##
          revisionHistoryLimit: 10

          ## Default 404 backend
          ##
          defaultBackend:

            ## If false, controller.defaultBackendService must be provided
            ##
            enabled: true

            name: default-backend
            image:
              repository: k8s.gcr.io/defaultbackend-amd64
              tag: "1.5"
              pullPolicy: IfNotPresent
              # nobody user -> uid 65534
              runAsUser: 65534

            extraArgs: {}

            serviceAccount:
              create: true
              name:
            ## Additional environment variables to set for defaultBackend pods
            extraEnvs: []

            port: 8080

            ## Readiness and liveness probes for default backend
            ## Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/
            ##
            livenessProbe:
              failureThreshold: 3
              initialDelaySeconds: 30
              periodSeconds: 10
              successThreshold: 1
              timeoutSeconds: 5
            readinessProbe:
              failureThreshold: 6
              initialDelaySeconds: 0
              periodSeconds: 5
              successThreshold: 1
              timeoutSeconds: 5

            ## Node tolerations for server scheduling to nodes with taints
            ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
            ##
            tolerations: []
            #  - key: "key"
            #    operator: "Equal|Exists"
            #    value: "value"
            #    effect: "NoSchedule|PreferNoSchedule|NoExecute(1.6 only)"

            affinity: {}

            ## Security Context policies for controller pods
            ## See https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/ for
            ## notes on enabling and using sysctls
            ##
            podSecurityContext: {}

            # labels to add to the pod container metadata
            podLabels: {}
            #  key: value

            ## Node labels for default backend pod assignment
            ## Ref: https://kubernetes.io/docs/user-guide/node-selection/
            ##
            nodeSelector: {}

            ## Annotations to be added to default backend pods
            ##
            podAnnotations: {}

            replicaCount: 1

            minAvailable: 1

            resources:
              limits:
                cpu: 300m
                memory: 400Mi
              requests:
                cpu: 10m
                memory: 20Mi

            service:
              annotations: {}
              ## Deprecated, instead simply do not provide a clusterIP value
              omitClusterIP: false
              # clusterIP: ""

              ## List of IP addresses at which the default backend service is available
              ## Ref: https://kubernetes.io/docs/user-guide/services/#external-ips
              ##
              externalIPs: []

              loadBalancerIP: ""
              loadBalancerSourceRanges: []
              servicePort: 80
              type: ClusterIP

            priorityClassName: ""

          ## Enable RBAC as per https://github.com/kubernetes/ingress/tree/master/examples/rbac/nginx and https://github.com/kubernetes/ingress/issues/266
          rbac:
            create: true

          # If true, create & use Pod Security Policy resources
          # https://kubernetes.io/docs/concepts/policy/pod-security-policy/
          podSecurityPolicy:
            enabled: false

          serviceAccount:
            create: true
            name:

          ## Optional array of imagePullSecrets containing private registry credentials
          ## Ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
          imagePullSecrets: []
          # - name: secretName

          # TCP service key:value pairs
          # Ref: https://github.com/kubernetes/contrib/tree/master/ingress/controllers/nginx/examples/tcp
          ##
          tcp: {}
          #  8080: "default/example-tcp-svc:9000"

          # UDP service key:value pairs
          # Ref: https://github.com/kubernetes/contrib/tree/master/ingress/controllers/nginx/examples/udp
          ##
          udp: {}
          #  53: "kube-system/kube-dns:53"
    EOT
  }

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
