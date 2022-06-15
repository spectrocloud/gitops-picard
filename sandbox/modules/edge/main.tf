data "spectrocloud_cluster_profile" "edge_infra_profile" {
  # name = "store-edge-infra"
  name = var.infra_profile
}

data "spectrocloud_cluster_profile" "edge_app_profile" {
  # name = "store-edge-apps"
  name = var.app_profile
}

resource "spectrocloud_appliance" "this" {
  count = length(var.device_uuid)

  uid = lower("edge-${var.device_uuid[count.index]}")
  labels = {
    "cluster" = spectrocloud_cluster_import.this.id
    "name" = "edge-${var.location}"
  }
  wait = false
}

resource "spectrocloud_cluster_import" "this" {
  name               = "edge-${var.location}"
  cloud              = "generic"
  tags = ["imported:false"]
  cluster_profile {
      id = data.spectrocloud_cluster_profile.edge_infra_profile.id
      pack {
        name = "opensuse-k3s"
        tag = "1.21.12-k3s0"
        values = <<-EOT
        manifests:
          opensuse-k3s:
            stages:
              network:
              - if: '[ -f "/run/cos/live_mode" ]'
                files:
                - path: /tmp/cloud-init
                  permissions: 0644
                  owner: 0
                  group: 0
                  content: |

                    stages:
                      initramfs:
                      - name: "Setup users"
                        users:
                          p3os:
                            passwd: p3os
                      network:
                      - if: '[ ! -f "/run/cos/recovery_mode" ]'
                        name: "SSH keys"
                        authorized_keys:
                          p3os:
                          - github:saamalik
                          - github:jeremy-spectro
                          - github:3pings
        EOT
      }
  }
    cluster_profile {
      id = data.spectrocloud_cluster_profile.edge_app_profile.id
  }
}
