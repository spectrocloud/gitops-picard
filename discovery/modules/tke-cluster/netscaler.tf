################################  NETSCALER API/CP  ##############################################
resource "citrixadc_lbvserver" "api" {
  name        = "${local.n}_tke_api"
  ipv46       = var.netscaler_vip_api
  port        = 8443
  servicetype = "TCP"
  lbmethod    = "LEASTCONNECTION"
}
resource "citrixadc_servicegroup" "api" {
  servicegroupname = "${local.n}_tke_api"
  servicetype      = "TCP"
  lbvservers       = [citrixadc_lbvserver.api.name]
  lbmonitor        = "tcp"
  servicegroupmembers = formatlist(
    "${var.cluster_network}.%d:6443:1",
    # Skip the VIP (first ip)
    range(var.cluster_api_start_ip + 1, var.cluster_api_end_ip + 1)
  )
}
################################  NETSCALER NODE PORT  ###########################################
resource "citrixadc_lbvserver" "nodeport" {
  name        = "${local.n}_tke_nodeport"
  ipv46       = var.netscaler_vip_nodeport
  port        = 65535
  servicetype = "TCP"
  lbmethod    = "LEASTCONNECTION"
}
resource "citrixadc_servicegroup" "nodeport" {
  servicegroupname = "${local.n}_tke_nodeport"
  servicetype      = "TCP"
  lbvservers       = [citrixadc_lbvserver.nodeport.name]
  servicegroupmembers = formatlist(
    "${var.cluster_network}.%d:65535:1",
    range(var.cluster_worker_start_ip, var.cluster_worker_end_ip + 1)
  )
}
################################  NETSCALER INGRESS  ###########################################
resource "citrixadc_lbvserver" "ingress" {
  name        = "${local.n}_tke_ingress"
  ipv46       = var.netscaler_vip_ingress
  port        = 443
  servicetype = "TCP"
  lbmethod    = "LEASTCONNECTION"
}
resource "citrixadc_servicegroup" "ingress" {
  servicegroupname = "${local.n}_tke_ingress"
  servicetype      = "TCP"
  lbvservers       = [citrixadc_lbvserver.ingress.name]
  lbmonitor        = "tcp"
  servicegroupmembers = formatlist(
    "${var.cluster_network}.%d:30000:1",
    range(var.cluster_worker_start_ip, var.cluster_worker_end_ip + 1)
  )
}
