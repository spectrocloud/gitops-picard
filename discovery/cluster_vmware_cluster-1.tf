#################################################################################################
##################################### MODIFY cluster-1 params ###################################
#################################################################################################

locals {
  # Cluster
  fqdn_cluster-1     = "cluster-1.discovery.spectrocloud.com"
  issuer_cluster-1   = "dex.${local.fqdn_cluster-1}"
  network_cluster-1  = "10.10.242"
  start_ip_cluster-1 = "20"
  end_ip_cluster-1   = "34"

  # Specify Front-facing netscaler VIPs
  cp_vip_cluster-1       = "10.10.182.2"
  nodeport_vip_cluster-1 = "10.10.182.3"
  ingress_vip_cluster-1  = "10.10.182.4"
}

#################################################################################################
##################################### DO NOT MODIFY BELOW #######################################
#################################################################################################


################################  NETSCALER API/CP  ##############################################

resource "citrixadc_lbvserver" "cp-cluster-1" {
  name        = "cluster-1_tke_api"
  ipv46       = local.cp_vip_cluster-1
  port        = 8443
  servicetype = "TCP"
  lbmethod    = "LEASTCONNECTION"
}

resource "citrixadc_servicegroup" "cp-cluster-1" {
  servicegroupname = "cluster-1_tke_api"
  servicetype      = "TCP"
  lbvservers       = [citrixadc_lbvserver.cp-cluster-1.name]
  lbmonitor        = "tcp"
  #servicegroupmembers = ["172.20.0.20:200:50","172.20.0.101:80:10",  "172.20.0.10:80:40"]
  servicegroupmembers = formatlist(
    "${local.network_cluster-1}.%d:6443:1",
    range(local.start_ip_cluster-1, local.start_ip_cluster-1 + 5)
  )
}

################################  NETSCALER NODE PORT  ###########################################

resource "citrixadc_lbvserver" "nodeport-cluster-1" {
  name        = "cluster-1_tke_nodeport"
  ipv46       = local.nodeport_vip_cluster-1
  port        = 65535
  servicetype = "TCP"
  lbmethod    = "LEASTCONNECTION"
}

resource "citrixadc_servicegroup" "nodeport-cluster-1" {
  servicegroupname = "cluster-1_tke_nodeport"
  servicetype      = "TCP"
  lbvservers       = [citrixadc_lbvserver.nodeport-cluster-1.name]
  #servicegroupmembers = ["172.20.0.20:200:50","172.20.0.101:80:10",  "172.20.0.10:80:40"]
  servicegroupmembers = formatlist(
    "${local.network_cluster-1}.%d:65535:1",
    range(local.start_ip_cluster-1 + 5, local.end_ip_cluster-1 + 1)
  )
}

################################  NETSCALER INGRESS  ###########################################

resource "citrixadc_lbvserver" "ingress-cluster-1" {
  name        = "cluster-1_tke_ingress"
  ipv46       = local.ingress_vip_cluster-1
  port        = 443
  servicetype = "TCP"
  lbmethod    = "LEASTCONNECTION"
}

resource "citrixadc_servicegroup" "ingress-cluster-1" {
  servicegroupname = "cluster-1_tke_ingress"
  servicetype      = "TCP"
  lbvservers       = [citrixadc_lbvserver.ingress-cluster-1.name]
  lbmonitor        = "tcp"
  #servicegroupmembers = ["172.20.0.20:200:50","172.20.0.101:80:10",  "172.20.0.10:80:40"]
  servicegroupmembers = formatlist(
    "${local.network_cluster-1}.%d:30000:1",
    range(local.start_ip_cluster-1 + 5, local.end_ip_cluster-1 + 1)
  )
}


################################  Clusters   ####################################################

locals {
  oidc_cluster-1 = replace(local.oidc_args_string, "%ISSUER_URL%", local.issuer_cluster-1)
  k8s_values_cluster-1 = replace(
    data.spectrocloud_pack.k8s-vsphere.values,
    "/apiServer:\\n\\s+extraArgs:/",
    indent(2, <<-EOT
      apiServer:
        certSANs: ["${local.fqdn_cluster-1}"]
        extraArgs:
          ${indent(4, local.oidc_cluster-1)}
      EOT
    )
  )
}


resource "spectrocloud_privatecloudgateway_ippool" "cluster-1" {
  private_cloud_gateway_id   = local.global_pcg_id
  name                       = "cluster-1"
  network_type               = "range"
  ip_start_range             = "${local.network_cluster-1}.${local.start_ip_cluster-1}"
  ip_end_range               = "${local.network_cluster-1}.${local.end_ip_cluster-1}"
  prefix                     = local.global_network_prefix
  gateway                    = local.global_network_gateway
  nameserver_addresses       = local.global_network_nameserver_addresses
  restrict_to_single_cluster = false
  #nameserver_search_suffix = ["test.com"]
}

resource "spectrocloud_cluster_vsphere" "cluster-1" {
  name               = "vmware-cluster-1"
  cluster_profile_id = spectrocloud_cluster_profile.ifcvmware.id
  cloud_account_id   = data.spectrocloud_cloudaccount_vsphere.this.id

  cloud_config {
    ssh_key = local.global_ssh_public_key

    datacenter = local.global_datacenter
    folder     = "${local.global_vm_folder}/spc-vmware-cluster-1"

    static_ip = true
  }

  # pack {
  #   name   = "vault"
  #   tag    = ""
  #   values = local.k8s_values_cluster-1
  # }

  pack {
    name   = "kubernetes"
    tag    = "1.18.15"
    values = local.k8s_values_cluster-1
  }

  pack {
    name   = "dex"
    tag    = "2.28.0"
    values = templatefile("config/dex_config.yaml", { issuer : local.issuer_cluster-1 })
  }

  pack {
    name   = "spectro-byo-manifest"
    tag    = "1.0.0"
    values = <<-EOT
      manifests:
        byo-manifest:
          contents: |
            apiVersion: v1
            kind: Secret
            metadata:
              name: ldap-secret
              namespace: dex
            data:
              bindpw: QWJjMTIzNDUh
              role_id: NzRjYjBjZDYtODlhMi0yNjkzLTdmMzgtZDJiMTk2ZjhkNDlj
              secret_id: MGE0NTE2NWQtNWUwYi0yMWMwLWU5NzEtNWQyZDM3NTA1YzYw
            ---
            apiVersion: v1
            kind: ConfigMap
            metadata:
              name: vaultconfig
              namespace: dex
            data:
              config-init.hcl: |
                exit_after_auth = true

                pid_file = "/home/vault/pidfile"

                auto_auth {
                  method "approle" {
                    mount_path = "auth/approle"
                    config = {
                      role_id_file_path = "/vault/custom/role_id"
                      secret_id_file_path = "/vault/custom/secret_id"
                      remove_secret_id_file_after_reading = false
                    }
                  }

                  sink "file" {
                    config = {
                      path = "/home/vault/.vault-token"
                    }
                  }
                }

                template {
                  destination = "/vault/secrets/config"
                  contents = <<-EOD
                    {{ with secret "secret/ldap/creds" }}
                      export BINDDN="{{ .Data.bind_dn }}"
                      export BINDPW="{{ .Data.bind_pw }}"
                    {{ end }}
                  EOD
                }

                vault {
                  address = "http://vault.app.picard.spectrocloud.com:8200"
                }
            ---
            apiVersion: v1
            kind: Secret
            type: kubernetes.io/tls
            metadata:
              name: default-tls
              namespace: nginx
            stringData:
              tls.crt: |
                -----BEGIN CERTIFICATE-----
                MIIDcjCCAlqgAwIBAgIUFAxr8A9CrFKy36utGf5LbiJk0ucwDQYJKoZIhvcNAQEL
                BQAwDTELMAkGA1UEAxMCY2EwHhcNMjEwMzA3MjMxMDM2WhcNMjEwNDA4MjMxMTA1
                WjAxMS8wLQYDVQQDDCYqLmNsdXN0ZXItMS5kaXNjb3Zlcnkuc3BlY3Ryb2Nsb3Vk
                LmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALn8LekOlYdCJvN/
                jL/p66gUleud5XQ3OXcsJR44J7+wpW+/prn7fKuelQc1RTqDgnw/M2/aW1VuHOz6
                i1hBOSpafnY1wXClW19CCVYl0IaAQPdhp5XZ2DzkTgygB8TETG91j6iwffV5xChA
                Ib3feH995eOuRVjAyDFPeNmZbAIVW6H9AOZ6Qx1pnLhirDIE2gYLB2PLueKG8+dn
                eczqe4wNSfvyeQeLphQI1dfdldFgyHFqQy0W/tpdl/5BiPq2V8PWjYLHQhSYh3fr
                PkLsNBXK3B7JHsmSDn5lXAMsVqgXZLqGIgB2R9XRbRi+mdtu0ePaJCGNfhH6YniD
                jbMn118CAwEAAaOBpTCBojAOBgNVHQ8BAf8EBAMCA6gwHQYDVR0lBBYwFAYIKwYB
                BQUHAwEGCCsGAQUFBwMCMB0GA1UdDgQWBBT8xCMbxRaLtYXgRG8QKJNStAlv7TAf
                BgNVHSMEGDAWgBQMCA4JymBTdvhB3Z9lqJYqAAWHizAxBgNVHREEKjAogiYqLmNs
                dXN0ZXItMS5kaXNjb3Zlcnkuc3BlY3Ryb2Nsb3VkLmNvbTANBgkqhkiG9w0BAQsF
                AAOCAQEAIyt4vEE50pzTM8vvbYS769/Giklf2dU9qP/+i+NIvTWuPlOJ2oQq6MZw
                01qZes/hc38ACsKWvs5rgKrZ3ccYsa2ac1FwqGyA5OCxJXd29Tg4h8hemEKWcAW3
                tj1UDJWGv/XBXsOPwhFgBPCQyNwi2odbxAVZyywq4mWGe8RU2/ZhJ9A5xqEtQ8xO
                YAgxW08SfcsuOQr46nndgjWjPtoMmnjRvNw7v46D/SMLjqfqhEq4FJpf0ThWCTbl
                bJCIEwQpxHIxbTUx6HdZiOgvsW4H1Y9dQeINo+rUZ4J4u69zqrrTdQJzOgocwtrE
                Nh+bppXoqqohlchxrcGsTy8692rbYg==
                -----END CERTIFICATE-----
                -----BEGIN CERTIFICATE-----
                MIIDHzCCAgegAwIBAgIUPnyIjRDCVH4dXT1/uaaW5HvHyjowDQYJKoZIhvcNAQEL
                BQAwEjEQMA4GA1UEAwwHcm9vdF9jYTAeFw0yMTAzMDYyMjIxNDBaFw0yNjExMTkw
                NjIyMTBaMA0xCzAJBgNVBAMTAmNhMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
                CgKCAQEAmQp2aMnnzSGqHTxHWCIfLmtsp6RitzrI60TGpK9FF/FASVufqoO55zc2
                hvO0I09u5N3733O5F3rrySB/gtKNbZbeUpDeGcoQTtzND+cAXuXCs/eiENH3Oawl
                5bnfn9kKM4W40dTtuvsz3EWDIADEHvxrg86hxT5S9ItM/Q3xFZYwHuABwfBS/+Dz
                kM8d9P6ktLsYX/aiEMXac34bAqV55QbnnoFkgWt7TiZWXBWQQ+p0LcapuSOXpGyC
                rBWtib/FMd6J5bwrd9MrqAdaji3d277EFe/zh+Dlp3GGQVQD2i1Y0XoITvtMUPoW
                eU/3r2M5TQSj6DNFqjCyr+k94sZO1QIDAQABo3IwcDAOBgNVHQ8BAf8EBAMCAQYw
                DwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUDAgOCcpgU3b4Qd2fZaiWKgAFh4sw
                HwYDVR0jBBgwFoAURDKinSTAOidcfdlcl8ooP/whh5gwDQYDVR0RBAYwBIICY2Ew
                DQYJKoZIhvcNAQELBQADggEBAKyigeRI/yk4b2nclP5CkfUVncb7+r0wU16FruB4
                gbVKdLWtxQQG0FYZRITC3+L30dOC+CAgx8emWUnGEzma+XNYIiOU9KCqNf8DfRb/
                NHAyNK8cAW/znNhRKT7AJfE+N1Dtsr1b4suKkBnMPM4RBN/QWkcq/Aj5SYQnocFW
                Pqo8OdddDsBz+XJRX15qFHZLAJh8vLKt/X29xs5c00CJK3FWHc+dd1m4wxzKLhPq
                oQrd1w+p9N0Ae6OevZy9J8Ys25EmXDyQ+PezwiH0eTbqLmJWIDtEpGxzjba8/ytz
                OtSYIfbls6/kUtQPOGfWPDQPNX9U7GtajOgy/XVi4qmeFH8=
                -----END CERTIFICATE-----
              tls.key: |
                -----BEGIN RSA PRIVATE KEY-----
                MIIEowIBAAKCAQEAufwt6Q6Vh0Im83+Mv+nrqBSV653ldDc5dywlHjgnv7Clb7+m
                uft8q56VBzVFOoOCfD8zb9pbVW4c7PqLWEE5Klp+djXBcKVbX0IJViXQhoBA92Gn
                ldnYPORODKAHxMRMb3WPqLB99XnEKEAhvd94f33l465FWMDIMU942ZlsAhVbof0A
                5npDHWmcuGKsMgTaBgsHY8u54obz52d5zOp7jA1J+/J5B4umFAjV192V0WDIcWpD
                LRb+2l2X/kGI+rZXw9aNgsdCFJiHd+s+Quw0FcrcHskeyZIOfmVcAyxWqBdkuoYi
                AHZH1dFtGL6Z227R49okIY1+EfpieIONsyfXXwIDAQABAoIBACyDC2Xc5LKjhXj/
                jOsdjBYFH0Bt4M2ores0uIl7/R9moqGVJ80ZQGQ+pwI7oJ75fJBJ/ACILRXMLcYV
                zKXJrmnRkLSv9uUD3lN1FZD1qeuW5HWQfLBjm9ou9fMVleZk6LpAU6qW2v6WLvlH
                KAwuYMN6mTudqOEt+nu6vnytuGji1HywLZN4wqKddSxmS2Cas9BvaUcHclkJNQEd
                LUWwTywm5PHswB3ks64N+8CqHwZWzKF4ABfJ3+YpHywn1tg76SVBNPSI5SLcDodK
                6LG7W/LFAzNXAh4rEQZEgDLmv1uPRsUcdGc7lkPq48UjYoPO3qC1uKnPbYS/ioln
                011BaHECgYEAwT6STCIPZcyO8P6SLfSBGT5T5wsPVjKJRmwXxpbU7HvvaTg3XNTn
                1ShRVHUPVZDzBYFyYWP15N26D283mvXDnpoXh+JWzAE2oFIKnovGwM/oN+lHZp04
                rEI3VSYS0bQrjC43s/n5x9Dc/dSyIwFO4SUDurloriPcMWBKwbYOr8kCgYEA9mIZ
                qprTQQRF45iXx7h2P5xlFW/RmdmeGWz6bl6/WhOPNjF/LXSMYrkgTsusGHPouhIN
                oQ8IuPjqzaBGH3BpZ+FSnMAGBNekqsk20SiYTwVu28LUZVLEPH6l4g1xv4qW41SE
                Mz2zl74JP9oWjndCnbnJ3vG/VlErzJKLVmiT8ecCgYEArDS4ZoQLuKn7z6LsXWuA
                CCDU4BWpCyVp04nL/jq3cC5ZgSiJnX5VQkz1fQ/8JEJRbtyWM1fC7rrwbYSsxriw
                JIwo3/zBYHbMWT4DHJpu+a/MvtZxvG3q7QbtDEIrjxjBneAp34aqInhsFv8N58fo
                pRY5JpLHSDfIp2+p7snweJECgYBJNx+vbfDHClEGcCryY6NoBb6YHzFnCZ8MqTDG
                KYutZdCR5yWGyXKKR78NC0MpxQ/scz7vlHsgFIAZ+L29y/bWssOM5xciyz4YrlCG
                2QxhtxiZX40kSvMbkvsScLJTnAh4p33diEFdH1C6U8GONmxqWHJfuPEF4nskgIu9
                crg8EwKBgD/Z1gWg9EYeP2xdB5ArfR+K2JsO41B+3epbqyFeWDUuc2vN8jI5B/S5
                N+aJza68t7SyRjY82zqhi1nH6LsAd2/ERFG5FA0a9AVthss44wYiX6Vrb1h9kW6F
                iL5nCNnJOpuII0fw7xJdhNAEBqH/osMniE8czBmn4LmCNS1Qz9YQ
                -----END RSA PRIVATE KEY-----
    EOT
  }


  # Not in T-Mo
  pack {
    name   = "lb-metallb"
    tag    = "0.9.5"
    values = <<-EOT
      manifests:
        metallb:
          # New
          namespace: "metallb-system"
          avoidBuggyIps: true
          addresses:
          - 10.10.242.100-10.10.242.109
    EOT
  }

  machine_pool {
    control_plane           = true
    control_plane_as_worker = false
    name                    = "master-pool"
    count                   = 3

    placement {
      cluster           = "cluster1"
      resource_pool     = ""
      datastore         = "datastore54"
      network           = "VM Network 2"
      static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.cluster-1.id
    }
    placement {
      cluster           = "cluster2"
      resource_pool     = ""
      datastore         = "datastore55"
      network           = "VM Network 2"
      static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.cluster-1.id
    }
    placement {
      cluster           = "cluster3"
      resource_pool     = ""
      datastore         = "datastore56"
      network           = "VM Network 2"
      static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.cluster-1.id
    }
    instance_type {
      disk_size_gb = 61
      memory_mb    = 4096
      cpu          = 2
    }
  }

  machine_pool {
    name  = "worker-pool"
    count = 3
    placement {
      cluster           = "cluster1"
      resource_pool     = ""
      datastore         = "datastore54"
      network           = "VM Network 2"
      static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.cluster-1.id
    }
    placement {
      cluster           = "cluster2"
      resource_pool     = ""
      datastore         = "datastore55"
      network           = "VM Network 2"
      static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.cluster-1.id
    }
    placement {
      cluster           = "cluster3"
      resource_pool     = ""
      datastore         = "datastore56"
      network           = "VM Network 2"
      static_ip_pool_id = spectrocloud_privatecloudgateway_ippool.cluster-1.id
    }
    instance_type {
      disk_size_gb = 61
      memory_mb    = 4096
      cpu          = 2
    }
  }
}
