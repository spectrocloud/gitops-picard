locals {
  profiles_files = fileset("${path.module}/config", "profile-*.yaml")
  cluster_profiles = {
    for k in local.profiles_files :
    trimsuffix(k, ".yaml") => yamldecode(file("config/${k}"))
  }
}

# profile_ids = {
#   for k, v in spectrocloud_cluster_profile.this :
#   v.name => v.id
# }

# rbac_yaml    = yamldecode(file("rbac.yaml"))
# rbac_all_crb = lookup(local.rbac_yaml.all_clusters, "clusterRoleBindings", [])
# rbac_all_rb  = lookup(local.rbac_yaml.all_clusters, "namespaces", [])
# rbac_all_crb = lookup(local.rbac_yaml.all_clusters, "clusterRoleBindings", [])
# rbac_all_rb  = lookup(local.rbac_yaml.all_clusters, "namespaces", [])
#
# rbac_map = {
#   for k, v in local.rbac_yaml.clusters :
#   k => {
#     clusterRoleBindings = concat(local.rbac_all_crb, lookup(v, "clusterRoleBindings", []))
#     namespaces        = concat(local.rbac_all_rb, lookup(v, "namespaces", []))
#   }
# }

################################  Cluster Profile #################################################

locals {
  profile_ids = merge({
    // TODO rename to aws
    ProdEKS-minimum = data.spectrocloud_cluster_profile.prodeks_min.id
    # ProdEKS-1    = spectrocloud_cluster_profile.this.id
    # ProdVMware-1 = data.spectrocloud_cluster_profile.vmware.id
    }, {
    for k, v in spectrocloud_cluster_profile.generic :
    v.name => v.id
  })
}

data "spectrocloud_cluster_profile" "prodeks_min" {
  name = "ProdEKS-minimum"
}

resource "spectrocloud_cluster_profile" "generic" {
  for_each = local.cluster_profiles
  name     = each.value.name

  description = each.value.description
  type        = each.value.type

  dynamic "pack" {
    for_each = each.value.packs
    content {
      name   = pack.value.name
      type   = pack.value.type
      values = <<-EOT
        pack:
          spectrocloud.com/install-priority: "${pack.value.install-priority}"
      EOT

      dynamic "manifest" {
        for_each = pack.value.argo_manifests
        content {
          name    = manifest.value.name
          content = <<-EOT
            apiVersion: argoproj.io/v1alpha1
            kind: Application
            metadata:
              name: ${manifest.value.name}
              namespace: argocd
              finalizers:
              - resources-finalizer.argocd.argoproj.io
            spec:
              destination:
                server: 'https://kubernetes.default.svc'
                namespace: ${manifest.value.namespace}
              source:
                repoURL: ${lookup(manifest.value.source, "repoURL", each.value.defaultRepoURL)}
                chart: ${manifest.value.source.chart}
                targetRevision: ${manifest.value.source.version}
                helm:
                  parameters: ${jsonencode(manifest.value.parameters)}
              project: default
              syncPolicy:
                automated:
                  selfHeal: false
                  prune: true
                syncOptions:
                - CreateNamespace=true
          EOT
        }
      }
    }
  }
}

#${indent(6, replace(yamlencode(manifest.value.parameters), "/((?:^|\n)[\\s-]*)\"([\\w-]+)\":/", "$1$2:"))}
# manifest {
#   name    = "ehs-rabbitmq"
#   content = <<-EOT
#     apiVersion: argoproj.io/v1alpha1
#     kind: Application
#     metadata:
#       name: ehs-rabbitmq
#       namespace: argocd
#       finalizers:
#       - resources-finalizer.argocd.argoproj.io
#     spec:
#       destination:
#         server: 'https://kubernetes.default.svc'
#         namespace: ehs-rabbitmq
#       source:
#         repoURL: 593235963820.dkr.ecr.us-west-2.amazonaws.com
#         targetRevision: 8.15.2
#         chart: helm/rabbitmq
#       project: default
#       syncPolicy:
#         automated:
#           selfHeal: false
#           prune: true
#         syncOptions:
#         - CreateNamespace=true
#   EOT
# }
# manifest {
#   name    = "ehs-postgresql"
#   content = <<-EOT
#     apiVersion: argoproj.io/v1alpha1
#     kind: Application
#     metadata:
#       name: ehs-postgresql
#       namespace: argocd
#       finalizers:
#       - resources-finalizer.argocd.argoproj.io
#     spec:
#       destination:
#         server: 'https://kubernetes.default.svc'
#         namespace: ehs-postgresql
#       source:
#         repoURL: 593235963820.dkr.ecr.us-west-2.amazonaws.com
#         targetRevision: 10.4.9
#         chart: helm/postgresql
#         helm:
#           parameters:
#           - name: persistence.size
#             value: 2Gi
#       project: default
#       syncPolicy:
#         automated:
#           selfHeal: false
#           prune: true
#         syncOptions:
#         - CreateNamespace=true
#   EOT
# }
# }

# pack {
# name   = "ehs-platform"
# type   = "manifest"
# values = <<-EOT
#   pack:
#     spectrocloud.com/install-priority: "20"
# EOT

# manifest {

#   name    = "ehs-spark"
#   content = <<-EOT
#     apiVersion: argoproj.io/v1alpha1
#     kind: Application
#     metadata:
#       name: ehs-spark
#       namespace: argocd
#       finalizers:
#       - resources-finalizer.argocd.argoproj.io
#     spec:
#       destination:
#         server: 'https://kubernetes.default.svc'
#         namespace: ehs-spark
#       source:
#         repoURL: 593235963820.dkr.ecr.us-west-2.amazonaws.com
#         chart: helm/spark
#         targetRevision: 5.4.4
#         helm:
#           parameters:
#           - name: spark.testing
#             value: 2Gi
#       project: default
#       syncPolicy:
#         automated:
#           selfHeal: false
#           prune: true
#         syncOptions:
#         - CreateNamespace=true
#   EOT
# }
# }

# pack {
# name   = "ehs-app1"
# type   = "manifest"
# values = <<-EOT
#   pack:
#     spectrocloud.com/install-priority: "30"
# EOT

# manifest {

#   name    = "ehs-app1"
#   content = <<-EOT
#     apiVersion: argoproj.io/v1alpha1
#     kind: Application
#     metadata:
#       name: ehs-app1
#       namespace: argocd
#       finalizers:
#       - resources-finalizer.argocd.argoproj.io
#     spec:
#       destination:
#         server: 'https://kubernetes.default.svc'
#         namespace: ehs-app1
#       source:
#         repoURL: 593235963820.dkr.ecr.us-west-2.amazonaws.com
#         chart: helm/nginx
#         targetRevision: 9.1.0
#         helm:
#           parameters:
#           - name: app.testing
#             value: cool
#       project: default
#       syncPolicy:
#         automated:
#           selfHeal: false
#           prune: true
#         syncOptions:
#         - CreateNamespace=true
#   EOT
# }
# }
# }
