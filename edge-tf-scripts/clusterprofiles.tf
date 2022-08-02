data "spectrocloud_registry_oci" "prod-azure" {
  name = "picard-prod-azure"
}

resource "spectrocloud_cluster_profile" "profile" {
  name        = "edge-store-web"
  description = "web apps"
  tags        = ["dev"]
  type        = "add-on"
  version = "2.0.0"

  pack {
    name = "manifest-namespace"
    type = "manifest"
    manifest {
      name    = "manifest-namespace"
      content = <<-EOT
        apiVersion: v1
        kind: Namespace
        metadata:
          labels:
            app: wordpress
            app3: wordpress786
          name: wordpress
      EOT
    }
    #uid    = "spectro-manifest-pack"
  }

  pack {
    name         = "hello-world"
    registry_uid = data.spectrocloud_registry_oci.prod-azure.id
    tag          = "0.1.0"
    type         = "oci"
    values       = <<-EOT
      pack:
        namespace: "hello-world"
        spectrocloud.com/install-priority: "10"
      values:
        hello-world:
          replicaCount: 1
    EOT
  }

  pack {
    name         = "mongodb"
    registry_uid = data.spectrocloud_registry_oci.prod-azure.id
    tag          = "6.0.1"
    type         = "oci"
    values       = <<-EOT
      pack:
        namespace: "mongodb"
        spectrocloud.com/install-priority: "0"
      values:
        mongodb:
          replicaCount: 1
          storageClassName: default
    EOT
  }

  pack {
    name         = "hipster"
    registry_uid = data.spectrocloud_registry_oci.prod-azure.id
    tag          = "0.2.0"
    type         = "oci"
    values       = <<-EOT
      pack:
        namespace: "hipster-app"
        spectrocloud.com/install-priority: "0"
      values:
        hipster:
          replicaCount: 1
          service:
            type: ClusterIP
            port: 80
          # image:
          #   repository: nginx
          #   pullPolicy: IfNotPresent
          #   # Overrides the image tag whose default is the chart appVersion.
          #   tag: ""

          imagePullSecrets: []
    EOT
  }

}

resource "spectrocloud_cluster_profile" "profile2" {
  name        = "edge-store-web"
  description = "web apps"
  tags        = ["dev"]
  type        = "add-on"
  version = "3.0.0"

  pack {
    name = "manifest-namespace"
    type = "manifest"
    manifest {
      name    = "manifest-namespace"
      content = <<-EOT
        apiVersion: v1
        kind: Namespace
        metadata:
          labels:
            app: wordpress
            app3: wordpress786
          name: wordpress
      EOT
    }
    #uid    = "spectro-manifest-pack"
  }

  pack {
    name         = "hello-world"
    registry_uid = data.spectrocloud_registry_oci.prod-azure.id
    tag          = "0.1.0"
    type         = "oci"
    values       = <<-EOT
      pack:
        namespace: "hello-world"
        spectrocloud.com/install-priority: "10"
      values:
        hello-world:
          replicaCount: 1
    EOT
  }

  pack {
    name         = "mongodb"
    registry_uid = data.spectrocloud_registry_oci.prod-azure.id
    tag          = "6.0.1"
    type         = "oci"
    values       = <<-EOT
      pack:
        namespace: "mongodb"
        spectrocloud.com/install-priority: "0"
      values:
        mongodb:
          replicaCount: 1
          storageClassName: default
    EOT
  }

  pack {
    name         = "hipster"
    registry_uid = data.spectrocloud_registry_oci.prod-azure.id
    tag          = "0.3.0"
    type         = "oci"
    values       = <<-EOT
      pack:
        namespace: "hipster-app"
        spectrocloud.com/install-priority: "0"
      values:
        hipster:
          replicaCount: 1
          service:
            type: ClusterIP
            port: 80
          # image:
          #   repository: nginx
          #   pullPolicy: IfNotPresent
          #   # Overrides the image tag whose default is the chart appVersion.
          #   tag: ""

          imagePullSecrets: []
    EOT
  }

}
