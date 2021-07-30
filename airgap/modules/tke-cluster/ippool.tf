################################  IPPool API/CP  ##############################################
resource "spectrocloud_privatecloudgateway_ippool" "api" {
  private_cloud_gateway_id   = var.global_config.pcg_id
  name                       = "${local.n}-api"
  network_type               = "range"
  ip_start_range             = "${var.cluster_network}.${var.cluster_api_start_ip}"
  ip_end_range               = "${var.cluster_network}.${var.cluster_api_end_ip}"
  prefix                     = var.global_config.network_prefix
  nameserver_addresses       = var.global_config.network_nameserver_addresses
  gateway                    = local.current_network.gateway
  restrict_to_single_cluster = true
}

################################  IPPool Worker ##############################################
resource "spectrocloud_privatecloudgateway_ippool" "workers" {
  private_cloud_gateway_id   = var.global_config.pcg_id
  name                       = "${local.n}-workers"
  network_type               = "range"
  ip_start_range             = "${var.cluster_network}.${var.cluster_worker_start_ip}"
  ip_end_range               = "${var.cluster_network}.${var.cluster_worker_end_ip}"
  prefix                     = var.global_config.network_prefix
  nameserver_addresses       = var.global_config.network_nameserver_addresses
  gateway                    = local.current_network.gateway
  restrict_to_single_cluster = true
}
