#################################################################################################
##################################### MODIFY cluster-2 params ###################################
#################################################################################################

locals {
  # Cluster
  fqdn_cluster-2     = "cluster-2.discovery.spectrocloud.com"
  api_cluster-2      = "api-${local.fqdn_cluster-2}"
  issuer_cluster-2   = "dex.${local.fqdn_cluster-2}"
  network_cluster-2  = "10.10.242"
  start_ip_cluster-2 = "20"
  end_ip_cluster-2   = "34"

  # Specify Front-facing netscaler VIPs
  cp_vip_cluster-2             = "10.10.182.2"
  worker_ingress_vip_cluster-2 = "10.10.182.3"
}

#################################################################################################
##################################### DO NOT MODIFY BELOW #######################################
#################################################################################################


################################  NETSCALER   ####################################################


################################  Clusters   ####################################################

locals {
  oidc_cluster-2 = replace(local.oidc_args_string, "%ISSUER_URL%", local.issuer_cluster-2)
  k8s_values_cluster-2 = replace(
    replace(
      data.spectrocloud_pack.k8s-vsphere.values,
      "/apiServer:\\n\\s+extraArgs:/",
      indent(2, <<-EOT
        apiServer:
          certSANs: ["${local.api_cluster-2}"]
          extraArgs:
            ${indent(4, local.oidc_cluster-2)}
        EOT
      )
    ),
    "/extraVolumes:/",
    indent(6, trimspace(<<-EOT
      extraVolumes:
      - name: encryption-config
        hostPath: /etc/kubernetes/data-encryption.config
        mountPath: /etc/kubernetes/data-encryption.config
        readOnly: true
        pathType: File
      EOT
    ))
  )
}


resource "vault_generic_secret" "kubeconfig_cluster-2" {
  path      = "pe/secret/tke/admin_creds/admin_conf_cluster-2"
  data_json = <<-EOT
    {
      "kubeconfig" : "${replace(spectrocloud_cluster_vsphere.cluster-2.kubeconfig, "\n", "\\n")}"
    }
  EOT
}

resource "spectrocloud_cluster_vsphere" "cluster-2" {
  name               = "vmware-cluster-2"
  cluster_profile_id = spectrocloud_cluster_profile.ifcvmware.id
  cloud_account_id   = data.spectrocloud_cloudaccount_vsphere.this.id

  cloud_config {
    ssh_key = local.global_ssh_public_key

    datacenter = local.global_datacenter
    folder     = "${local.global_vm_folder}/spc-vmware-cluster-2"

    static_ip = false

    network_type          = "DDNS"
    network_search_domain = local.global_dhcp_search
  }

  # pack {
  #   name   = "vault"
  #   tag    = ""
  #   values = local.k8s_values_cluster-2
  # }

  pack {
    name   = "kubernetes"
    tag    = "1.18.15"
    values = local.k8s_values_cluster-2
  }

  pack {
    name   = "dex"
    tag    = "2.28.0"
    values = templatefile("config/dex_config.yaml", { issuer : local.issuer_cluster-2 })
  }

  pack {
    name = "spectro-byo-manifest"
    tag  = "1.0.0"
    values = templatefile("config/byom_v1.yaml", {
      vault_addr : local.global_vault_addr,
      certkey : <<-EOT
        tls.crt: |
          -----BEGIN CERTIFICATE-----
          MIIDcjCCAlqgAwIBAgIUJtjNj63M/gcvtnpLBg4TYIkbICQwDQYJKoZIhvcNAQEL
          BQAwDTELMAkGA1UEAxMCY2EwHhcNMjEwMzA5MDE0NjQ4WhcNMjEwNDEwMDE0NzE4
          WjAxMS8wLQYDVQQDDCYqLmNsdXN0ZXItMi5kaXNjb3Zlcnkuc3BlY3Ryb2Nsb3Vk
          LmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM3LmnOMzXeJerS8
          LwVQ754xVqUwiQeHoCayUNSEoT8bEtujx6LeohmtY3Ln8iXWENjmTVD7+7bvsKKc
          Mls2SElOLM155573E/qtmmaLP7jgrt/GkUnag8yTwJk+6IB38Yb0d3ie0NZ5TGvW
          HAEK3oMFHU7v3AITVdoN8UnkQ0OdfwompRyuqYG+bpnc//UjP3IzvdCiji+TUHuJ
          WTnWg0yMwOR5fMcRIme1qklnZ/X31L1CaVYRbf5/N6tDsEEQtwy8lhHaARE1Q1mM
          sxBPPKBQS5t8BkqcYIzKi9pV7z0swyatefdta/1jipN8VDSZgXqUt9sVLSeE9466
          r9ebqFkCAwEAAaOBpTCBojAOBgNVHQ8BAf8EBAMCA6gwHQYDVR0lBBYwFAYIKwYB
          BQUHAwEGCCsGAQUFBwMCMB0GA1UdDgQWBBT6Gtc5xbbWWkJ2yY6fnJxgW+QBgTAf
          BgNVHSMEGDAWgBQMCA4JymBTdvhB3Z9lqJYqAAWHizAxBgNVHREEKjAogiYqLmNs
          dXN0ZXItMi5kaXNjb3Zlcnkuc3BlY3Ryb2Nsb3VkLmNvbTANBgkqhkiG9w0BAQsF
          AAOCAQEAi+NouC3Si1ar+zJgrD8QDLooB2wRd6HsSVqr3nXNBEgB2Cp7+mwBMFhd
          DEKLKwFnV7CGIC8W0YGQJO5rdIJngsluow8HlNsDjYkj9QaPpEX1pvzpAR1tzWy1
          F7VDpzSddm1x4xAdYb5YyI5eHBthKAeUh32uKGGqoaCy3acXI94PNcpoShwIzV2r
          g+GFEYsg3gjUhfoS9HgQz8zSYns0sWN+kd0C+GGa3tCz9m3jbQia35ABeJoYZfsK
          tTFNGFnjRxwa9TuZ9no7PcZkvUAe0hYbTv5syCWnGoacL+VIgcMK8PXgKkr+yKIf
          hhqYhesDHn2EoA/0GuKRXWijFvwBNw==
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
          MIIEowIBAAKCAQEAzcuac4zNd4l6tLwvBVDvnjFWpTCJB4egJrJQ1IShPxsS26PH
          ot6iGa1jcufyJdYQ2OZNUPv7tu+wopwyWzZISU4szXnnnvcT+q2aZos/uOCu38aR
          SdqDzJPAmT7ogHfxhvR3eJ7Q1nlMa9YcAQregwUdTu/cAhNV2g3xSeRDQ51/Cial
          HK6pgb5umdz/9SM/cjO90KKOL5NQe4lZOdaDTIzA5Hl8xxEiZ7WqSWdn9ffUvUJp
          VhFt/n83q0OwQRC3DLyWEdoBETVDWYyzEE88oFBLm3wGSpxgjMqL2lXvPSzDJq15
          921r/WOKk3xUNJmBepS32xUtJ4T3jrqv15uoWQIDAQABAoIBAQDJbWmFg+FwCP4z
          fKXBXFDM05ntIa5d0l/swEfhWtfAvq0ckhfK0IJ1A4L9aw1V/0qKIhC3HYxop/6J
          iry3DlB+f6fWjmUo8Ml7aQRhLhZ2zGQd32tBkEHEsTGoTSyg4cVjxFBTnY7m/d7R
          BcZvNsZIE292XctHtMkpHtB29Jbpy7HilQu6g9uFvfS4NPkwiBzrrX+jz7I/mtSW
          8yfvFsmcl9sDvo8n9FYKzrX7+omovOYG47mSR4H2qHiiH4myGp3NLE5IS2gJ1+dm
          cmZcMjmNqjDyJGJkaZgfixs1wqLYgoFGEtmgkl/bVDUVF9sOx3SL8vtZWk/mf/qc
          qznt/UoJAoGBAPRd0C5D/mRCKI7cRSvdNSVxr9+ZJc61tWiTL5IpDu8U+icusB3m
          RrFyxWRRH05BmGM8mxQZOTHaAJYmHsclWNg8DRAc/v7JOG+ADXQqLxpXGkHEmqNm
          AqnFXh4vk2CBX/7LtR1927yUpeXEYec0CfewxUn/45Nl1x2pIcVHHP6jAoGBANeX
          tYaxKhSZ2HruD0tcAGfv4ypVeDTBWvzeYehTHxKUTJwTBgtrHgTCUKZ5lacnHejp
          N1KYfso94gwG2P0OYy0LqaSSfTi2R71bAqmlIKE6lNwUFFkQb75bbtgHZ78NAFB1
          GiAaWKdRGTWRzquFYjZbZmhS0XaBd1Cr25Hft5jTAoGAfBr5E8YseLaw6n0sFC7w
          QugOLj0VWnome8nkqxJ3Jy08LpIjl8vPs2daoKwifhgKULwC9p4o0gypp5gMoY9y
          I7+70qcnSjbflqEuNAUIjxQVnbk/4CR6zcYTGrmG28hY/IpwnV3CL3A/IQYvwsBH
          H6iDSiXPapiaO9Id+Jc5PokCgYAdSMgpgYsbvUIAgLGnJNoRRC5xI6buU41OZ86Y
          xiGkXmyBjrv1dRlgwBxAYKeJSvDvIC6Zk4k1Y25+/7cduISUK89hQVytBWV9PQ2B
          iaKDA/gQZNHWvzrOepD12xumgdeXFjD0R1/fak6oTiPqfHW4uHWSmh1FoZRZat6q
          U98WbQKBgGx9eyykR5uqu7JxFvQ3Ap8MATl7NJSApMy7Bp9HR2EePF2GkBgIxYKm
          DetGEOvRb9P8w3b5g7SnuLFqZ7Yth7wo15UUzCx7NFHeYjWnX4vyyMwZ9NlS+mPr
          ocGNwxkmd4k3lLv+SRNwmEHHLGZwa40jQ1LyOeANhGiv8NuPEOMq
          -----END RSA PRIVATE KEY-----
      EOT
    })
  }

  # # Intermittently during initial install the Vault agent MutatingWebHook is installed _after_ dex is already started
  # # During initial install only, force the dex pod to restart after cluster is "RUNNING" (all packs up and running)
  # provisioner "local-exec" {
  #   command     = "kubectl --kubeconfig <(echo \"${self.kubeconfig}\") -n dex delete pod -l app.kubernetes.io/name=dex"
  #   interpreter = ["bash", "-c"]
  # }

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
          - 10.10.182.100-10.10.182.109
    EOT
  }

  machine_pool {
    control_plane           = true
    control_plane_as_worker = false
    name                    = "master-pool"
    count                   = 1

    placement {
      cluster       = "cluster1"
      resource_pool = ""
      datastore     = "datastore54"
      network       = "VM Network"
    }
    placement {
      cluster       = "cluster2"
      resource_pool = ""
      datastore     = "datastore55"
      network       = "VM Network"
    }
    placement {
      cluster       = "cluster3"
      resource_pool = ""
      datastore     = "datastore56"
      network       = "VM Network"
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
      cluster       = "cluster1"
      resource_pool = ""
      datastore     = "datastore54"
      network       = "VM Network"
    }
    placement {
      cluster       = "cluster2"
      resource_pool = ""
      datastore     = "datastore55"
      network       = "VM Network"
    }
    placement {
      cluster       = "cluster3"
      resource_pool = ""
      datastore     = "datastore56"
      network       = "VM Network"
    }
    instance_type {
      disk_size_gb = 61
      memory_mb    = 4096
      cpu          = 2
    }
  }
}
