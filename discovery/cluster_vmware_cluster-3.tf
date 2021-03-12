#################################################################################################
##################################### MODIFY cluster-3 params ###################################
#################################################################################################

locals {
  # Cluster
  issuer_cluster-3   = "dex.cluster-3.discovery.spectrocloud.com"
  network_cluster-3  = "10.10.242"
  start_ip_cluster-3 = "20"
  end_ip_cluster-3   = "34"

  # Specify Front-facing netscaler VIPs
  cp_vip_cluster-3             = "10.10.182.2"
  worker_ingress_vip_cluster-3 = "10.10.182.3"
}

#################################################################################################
##################################### DO NOT MODIFY BELOW #######################################
#################################################################################################


################################  NETSCALER   ####################################################

################################  Clusters   ####################################################

# locals {
#   oidc_cluster-3 = replace(local.oidc_args_string, "%ISSUER_URL%", local.issuer_cluster-3)
#   k8s_values_cluster-3 = replace(
#     data.spectrocloud_pack.k8s-vsphere.values,
#     "/apiServer:\\n\\s+extraArgs:/",
#     indent(6, "$0\n${local.oidc_cluster-3}\n#testtesttest")
#   )
# }

# resource "spectrocloud_cluster_vsphere" "cluster-3" {
#   name               = "vmware-cluster-3"
#   cluster_profile_id = spectrocloud_cluster_profile.ifcvmware.id
#   cloud_account_id   = data.spectrocloud_cloudaccount_vsphere.this.id

#   cloud_config {
#     ssh_key = local.global_ssh_public_key

#     datacenter = local.global_datacenter
#     folder     = "${local.global_vm_folder}/spc-vmware-cluster-3"

#     static_ip = false

#     network_type          = "DDNS"
#     network_search_domain = local.global_dhcp_search
#   }

#   # pack {
#   #   name   = "vault"
#   #   tag    = ""
#   #   values = local.k8s_values_cluster-3
#   # }

#   pack {
#     name   = "kubernetes"
#     tag    = "1.18.15"
#     values = local.k8s_values_cluster-3
#   }

#   pack {
#     name   = "dex"
#     tag    = "2.28.0"
#     values = templatefile("config/dex_config.yaml", { issuer : local.issuer_cluster-3 })
#   }

#   pack {
#     name   = "spectro-byo-manifest"
#     tag    = "1.0.0"
#     values = <<-EOT
#       manifests:
#         byo-manifest:
#           contents: |
#             apiVersion: v1
#             kind: Secret
#             metadata:
#               name: ldap-secret
#               namespace: dex
#             data:
#               bindpw: QWJjMTIzNDUh
#               role_id: NzRjYjBjZDYtODlhMi0yNjkzLTdmMzgtZDJiMTk2ZjhkNDlj
#               secret_id: MGE0NTE2NWQtNWUwYi0yMWMwLWU5NzEtNWQyZDM3NTA1YzYw
#             ---
#             apiVersion: v1
#             kind: ConfigMap
#             metadata:
#               name: vaultconfig
#               namespace: dex
#             data:
#               config-init.hcl: |
#                 exit_after_auth = true

#                 pid_file = "/home/vault/pidfile"

#                 auto_auth {
#                   method "approle" {
#                     mount_path = "auth/approle"
#                     config = {
#                       role_id_file_path = "/vault/custom/role_id"
#                       secret_id_file_path = "/vault/custom/secret_id"
#                       remove_secret_id_file_after_reading = false
#                     }
#                   }

#                   sink "file" {
#                     config = {
#                       path = "/home/vault/.vault-token"
#                     }
#                   }
#                 }

#                 template {
#                   destination = "/vault/secrets/config"
#                   contents = <<-EOD
#                     {{ with secret "secret/ldap/creds" }}
#                       export BINDDN="{{ .Data.bind_dn }}"
#                       export BINDPW="{{ .Data.bind_pw }}"
#                     {{ end }}
#                   EOD
#                 }

#                 vault {
#                   address = "http://vault.app.picard.spectrocloud.com:8200"
#                 }
#             ---
#             apiVersion: v1
#             kind: Secret
#             type: kubernetes.io/tls
#             metadata:
#               name: default-tls
#               namespace: nginx
#             stringData:
#               tls.crt: |
#                 -----BEGIN CERTIFICATE-----
#                 MIIDcjCCAlqgAwIBAgIUb9ANG6Eur/GW20Ez0g+x+fWEgW8wDQYJKoZIhvcNAQEL
#                 BQAwDTELMAkGA1UEAxMCY2EwHhcNMjEwMzEwMDIxMDUzWhcNMjEwNDExMDIxMTIy
#                 WjAxMS8wLQYDVQQDDCYqLmNsdXN0ZXItMy5kaXNjb3Zlcnkuc3BlY3Ryb2Nsb3Vk
#                 LmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJq6TUHbW+8RgWoQ
#                 O5n+pODXvS4DqlPIkvlavVIDTSyTD9JmrPJImhGADoOWTkystGfr6fLuoN19Gv5+
#                 niPMlQrTseA/E5ngcpz2+PFNFCM/H+RBTbhsXbbgUH0M1/IPc9ZzAuSPrkh8uYhD
#                 Fy8lQSUsyqlDYFGWD66OIeIC+DUHATBmjqvO0lu4NzgHJUtDd/bymYXZCPYVb7cM
#                 D1MNx1GVf0C+22yQsgAUzHXS0Hh5KliQSo4UZCrYqlip5mTG3eO9XaGMlUHYm4LX
#                 sG+YHF4j/LCcamseH5m28NPrKauqT63oq1VGSsZlUTzPPZcbX1gKkYZfj6y/BBdH
#                 GHLK4UsCAwEAAaOBpTCBojAOBgNVHQ8BAf8EBAMCA6gwHQYDVR0lBBYwFAYIKwYB
#                 BQUHAwEGCCsGAQUFBwMCMB0GA1UdDgQWBBS2z0heErbKAY/VzUaTlxOszCH5azAf
#                 BgNVHSMEGDAWgBQMCA4JymBTdvhB3Z9lqJYqAAWHizAxBgNVHREEKjAogiYqLmNs
#                 dXN0ZXItMy5kaXNjb3Zlcnkuc3BlY3Ryb2Nsb3VkLmNvbTANBgkqhkiG9w0BAQsF
#                 AAOCAQEAYjMT75ipyc5ATkwx1w1GKGg6S3WEt4d3FbBYzdNPVZtf4d78THucHdkQ
#                 JQyrB9zF7ZmUxVsD7GigfITjkEpw6Tf/Ol5Efkv0Bu3TasEG+LTJ3edf+xg0VdcG
#                 PR89ssyI/jjPEgPqGG+xJTaf2soZIaIOMu78u/FsseUyXpg3CY2kKHyTnfFiCsNb
#                 7w8FAzyaUsLi9lZ9EWee3YzysaLrlEKCm2HisJCYMVW+dBajhOUn+4wQlkevXfZr
#                 EGqOyxol/50YFftpakk3aU8NpA/XdaXx9Ue5cIQqnl2x5V5iIUJ4QrdkOQEDKhRi
#                 ktiK2ka1TmQaV3pRlhYFueyJ4+mirQ==
#                 -----END CERTIFICATE-----
#                 -----BEGIN CERTIFICATE-----
#                 MIIDHzCCAgegAwIBAgIUPnyIjRDCVH4dXT1/uaaW5HvHyjowDQYJKoZIhvcNAQEL
#                 BQAwEjEQMA4GA1UEAwwHcm9vdF9jYTAeFw0yMTAzMDYyMjIxNDBaFw0yNjExMTkw
#                 NjIyMTBaMA0xCzAJBgNVBAMTAmNhMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
#                 CgKCAQEAmQp2aMnnzSGqHTxHWCIfLmtsp6RitzrI60TGpK9FF/FASVufqoO55zc2
#                 hvO0I09u5N3733O5F3rrySB/gtKNbZbeUpDeGcoQTtzND+cAXuXCs/eiENH3Oawl
#                 5bnfn9kKM4W40dTtuvsz3EWDIADEHvxrg86hxT5S9ItM/Q3xFZYwHuABwfBS/+Dz
#                 kM8d9P6ktLsYX/aiEMXac34bAqV55QbnnoFkgWt7TiZWXBWQQ+p0LcapuSOXpGyC
#                 rBWtib/FMd6J5bwrd9MrqAdaji3d277EFe/zh+Dlp3GGQVQD2i1Y0XoITvtMUPoW
#                 eU/3r2M5TQSj6DNFqjCyr+k94sZO1QIDAQABo3IwcDAOBgNVHQ8BAf8EBAMCAQYw
#                 DwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUDAgOCcpgU3b4Qd2fZaiWKgAFh4sw
#                 HwYDVR0jBBgwFoAURDKinSTAOidcfdlcl8ooP/whh5gwDQYDVR0RBAYwBIICY2Ew
#                 DQYJKoZIhvcNAQELBQADggEBAKyigeRI/yk4b2nclP5CkfUVncb7+r0wU16FruB4
#                 gbVKdLWtxQQG0FYZRITC3+L30dOC+CAgx8emWUnGEzma+XNYIiOU9KCqNf8DfRb/
#                 NHAyNK8cAW/znNhRKT7AJfE+N1Dtsr1b4suKkBnMPM4RBN/QWkcq/Aj5SYQnocFW
#                 Pqo8OdddDsBz+XJRX15qFHZLAJh8vLKt/X29xs5c00CJK3FWHc+dd1m4wxzKLhPq
#                 oQrd1w+p9N0Ae6OevZy9J8Ys25EmXDyQ+PezwiH0eTbqLmJWIDtEpGxzjba8/ytz
#                 OtSYIfbls6/kUtQPOGfWPDQPNX9U7GtajOgy/XVi4qmeFH8=
#                 -----END CERTIFICATE-----
#               tls.key: |
#                 -----BEGIN RSA PRIVATE KEY-----
#                 MIIEpAIBAAKCAQEAmrpNQdtb7xGBahA7mf6k4Ne9LgOqU8iS+Vq9UgNNLJMP0mas
#                 8kiaEYAOg5ZOTKy0Z+vp8u6g3X0a/n6eI8yVCtOx4D8TmeBynPb48U0UIz8f5EFN
#                 uGxdtuBQfQzX8g9z1nMC5I+uSHy5iEMXLyVBJSzKqUNgUZYPro4h4gL4NQcBMGaO
#                 q87SW7g3OAclS0N39vKZhdkI9hVvtwwPUw3HUZV/QL7bbJCyABTMddLQeHkqWJBK
#                 jhRkKtiqWKnmZMbd471doYyVQdibgtewb5gcXiP8sJxqax4fmbbw0+spq6pPreir
#                 VUZKxmVRPM89lxtfWAqRhl+PrL8EF0cYcsrhSwIDAQABAoIBAHhx3gIOCBqpvdwa
#                 lsrhduewCQvwvn5J/F8vS4C0ITc5o29djfNsoMJOtP2p23nEVwsukgcRyxefc4v4
#                 dJHZh4vODwFJGLEIDzAw8Mil/68QTHsaeq29bZYWN5GgldlQPhQJo47YagrzTFnO
#                 IBYLIhMWMwxf7nKUJdDzw1x0g1KC01+4yhnlVzUevNGGTMJ8XCNu4Hq1RKrkxDWT
#                 IvX+m0zXTrPOkAcfQlgJvEr6LgKdmXCgYhg+w0jxBab418+A/DMJY8kyZ0QKVWsX
#                 YJikjGWgqx2vuk8SsGj9dG17Ysl1ufypeRFuG9yzKYfMvyaQSzbPhPip6yLiCISl
#                 d2tMZEECgYEAzWBE+TFf9ErjKdGbxwGOIsMRv8ycgomimnXm0M4Q4Miq8gcSkhpI
#                 JniLjsLWXw0oIWEBo7+Hgsy6rfkAQ75ERkxZEcmmZ12o0oetDLihkb/H5PYDoeGq
#                 Di8JfMHbMsMJ9KdXDt1Bc1vYuKERrqTsBfb6fdWvFE25BiifC52yrG0CgYEAwN4A
#                 DeXIGkUR+0svmiObFdsk9KcFsO+DLR5X+9/TlehoBl10jAM+LjKSAsir8uaKlODy
#                 ZX0sb6PyUOCdE4jMo8Zprnb//V1fylGc/fV7ZMqxmKPw8K/tOd0ZdFY6b47ceXFq
#                 XItpqEXSdL6ibRZ6aPWpxTUM9IrqUMGqMpBtwZcCgYEAp9l4RZl+7K+PvQvcnua8
#                 fdij1vepKl7GkCqv/BOOY8hdPfVdzh7AvQBkPscqYQDlvXIE3wmX/OTJ5YnOF4+X
#                 SUT4vrrpzy0S3w2X9v+mvPHas1wFV/aQ/4qd3GKrfW894cAqPLHD3j5Af5TUWMHd
#                 THqv+sv7jUKAZ3InmlzGPHkCgYAsA32nrkSYGiMcYfAfEPkXZ8drPaKC2mXpKf+S
#                 L2Yt07fJnBI40ZSjHk9L61eyOwJtL1ih6Ir3f0aRRnESQCnTRjhf5DBPNbvig/V7
#                 z0W1nrwgxWj6xGsyxU5FylfTlZqi7EsFi5s1F5oLomWW14Zf5ZA0vQKT3A/VFh0t
#                 JOCnSQKBgQCCiRiOGnixTqJ+MopHghJi/JZINDDuzbas953t0YVqpev5yECFlHAA
#                 8nYPu/wcw8VsQTATNdYLIIz50wDwlXQiXXrUxu5YeaSpIJJc6k6ZrPh8ukpYzXkl
#                 CI1LeXhJsJtKBRsjXWbgLFeB/xqWutILqFLUBTLlVAAmFKmAzlQR9g==
#                 -----END RSA PRIVATE KEY-----
#     EOT
#   }


#   # Not in T-Mo
#   pack {
#     name   = "lb-metallb"
#     tag    = "0.9.5"
#     values = <<-EOT
#       manifests:
#         metallb:
#           # New
#           namespace: "metallb-system"
#           avoidBuggyIps: true
#           addresses:
#           - 10.10.182.100-10.10.182.109
#     EOT
#   }

#   machine_pool {
#     control_plane           = true
#     control_plane_as_worker = false
#     name                    = "master-pool"
#     count                   = 1

#     placement {
#       cluster       = "cluster1"
#       resource_pool = ""
#       datastore     = "datastore54"
#       network       = "VM Network"
#     }
#     placement {
#       cluster       = "cluster2"
#       resource_pool = ""
#       datastore     = "datastore55"
#       network       = "VM Network"
#     }
#     placement {
#       cluster       = "cluster3"
#       resource_pool = ""
#       datastore     = "datastore56"
#       network       = "VM Network"
#     }
#     instance_type {
#       disk_size_gb = 61
#       memory_mb    = 4096
#       cpu          = 2
#     }
#   }

#   machine_pool {
#     name  = "worker-pool"
#     count = 3
#     placement {
#       cluster       = "cluster1"
#       resource_pool = ""
#       datastore     = "datastore54"
#       network       = "VM Network"
#     }
#     placement {
#       cluster       = "cluster2"
#       resource_pool = ""
#       datastore     = "datastore55"
#       network       = "VM Network"
#     }
#     placement {
#       cluster       = "cluster3"
#       resource_pool = ""
#       datastore     = "datastore56"
#       network       = "VM Network"
#     }
#     instance_type {
#       disk_size_gb = 61
#       memory_mb    = 4096
#       cpu          = 2
#     }
#   }
# }
