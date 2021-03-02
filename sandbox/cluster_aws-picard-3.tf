data "spectrocloud_cloudaccount_aws" "picard" {
  name = "aws-sa"
}

locals {
  aws_ssh_key_name = "default"
  aws_region       = "us-west-2"
  aws_region_az    = "us-west-2a"
}

# resource "local_file" "kubeconfig" {
#   content              = spectrocloud_cluster_aws.cluster.kubeconfig
#   filename             = "kubeconfig_aws-2"
#   file_permission      = "0644"
#   directory_permission = "0755"
# }

# output "cluster_kubeconfig" {
#   value = spectrocloud_cluster_aws.cluster.kubeconfig
# }

resource "spectrocloud_cluster_aws" "cluster" {
  name               = "aws-picard-3"
  cluster_profile_id = spectrocloud_cluster_profile.prodaws.id
  cloud_account_id   = data.spectrocloud_cloudaccount_aws.picard.id

  cloud_config {
    ssh_key_name = local.aws_ssh_key_name
    region       = local.aws_region
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
    instance_type           = "t3.large"
    disk_size_gb            = 62
    azs                     = [local.aws_region_az]
  }

  machine_pool {
    name          = "worker-basic"
    count         = 2
    instance_type = "t3.large"
    azs           = [local.aws_region_az]
  }

}
