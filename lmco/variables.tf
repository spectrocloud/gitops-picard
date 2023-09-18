
# SpectroCloud authentication variables
variable "sc_host" {}
variable "sc_api_key" {}
variable "sc_project_name" {}

# Cluster Config related
variable "aws_cloudaccount_name" {
  default     = "aws-gov-dev"
  description = "The cloud account from Palette to use for cluster provisioning"
}
variable "aws_ssh_key_name" {
  default     = "spectro2020"
  description = "The SSH key to use for cluster provisioning"
}
variable "aws_region" {
  default     = "us-gov-east-1"
  description = "The AWS region to use for cluster provisioning"
}
variable "aws_vpcid" {
  default     = "vpc-04906e2f9614976bf"
  description = "The AWS vpcId to use for cluster provisioning"
}
variable "control_plane_lb" {
  default     = ""  # [ Use `internal` for private API server]
  description = "The ControlPlane API Server LoadBalancer type to use for cluster provisioning"
}

# Machine Pool config
variable "default_instance_type" {
  default     = "t3.xlarge"
  description = "The aws instance type to use for EC2 instances"
}
variable "default_disk_size" {
  default     = 60
  description = "The disk size (in GB) for EC2 instances"
}

# Infra profile variables
variable "infra_profile_name" {
  default     = "aws-pxke-infra"
  description = "The infra profile to use for cluster provisioning"
}
variable "infra_profile_version" {
  default     = "1.27.2"
  description = "The infra profile version to use for cluster provisioning"
}

# Addon pack variables
variable "pack_name_argocd" {
  default     = "argo-cd"
  description = "ArgoCD pack name to use for the profile & cluster"
}
variable "pack_version_argocd" {
  default     = "3.26.7"
  description = "ArgoCD pack version to use for the profile & cluster"
}
/*
variable "pack_name_crowdstrike_falcon" {
  default     = "falcon-sensor"
  description = "CrowdStrike Falcon pack name to use for the profile & cluster"
}
variable "pack_version_crowdstrike_falcon" {
  default     = "1.0.0"
  description = "CrowdStrike Falcon pack version to use for the profile & cluster"
}*/
