#locals {
#  # Specify Cluster
#  network_cluster-1  = "10.142.148"
#  start_ip_cluster-1 = "80"
#  end_ip_cluster-1   = "99"

#  # Specify VIPs
#  cp_vip = "10.10.182.2"
#  worker_ingress_vip = "10.10.182.3"

#}

#resource "citrixadc_lbvserver" "cp-cluster-1" {
#  name = "cp-cluster-1"
#  ipv46 = local.cp_vip
#  port = 6443
#  servicetype = "SSL"
#  lbmethod = "ROUNDROBIN"
#  persistencetype = "COOKIEINSERT"
#  # sslcertkey = "${citrixadc_sslcertkey.foo.certkey}"
#  # sslprofile = "ns_default_ssl_profile_secure_frontend"
#}

#resource "citrixadc_servicegroup" "cp-cluster-1" {
#  servicegroupname = "cp-cluster-1"
#  servicetype      = "HTTP"
#  lbvservers = [citrixadc_lbvserver.cp-cluster-1.name]
#  ## TODO specify
#  #lbmonitor = "${citrixadc_lbmonitor.foo.name}"
#  #servicegroupmembers = ["172.20.0.20:200:50","172.20.0.101:80:10",  "172.20.0.10:80:40"]
#  servicegroupmembers = formatlist(
#    "${local.network_cluster-1}.%d:6443:1",
#    range(local.start_ip_cluster-1, local.start_ip_cluster-1 + 5)
#  )
#}

#resource "citrixadc_lbvserver" "worker-ingress-cluster-1" {
#  name = "worker-ingress-cluster-1"
#  ipv46 = local.worker_ingress_vip
#  port = 443
#  servicetype = "SSL"
#  lbmethod = "ROUNDROBIN"
#  persistencetype = "COOKIEINSERT"
#  # TODO?
#  # sslcertkey = "${citrixadc_sslcertkey.foo.certkey}"
#  # sslprofile = "ns_default_ssl_profile_secure_frontend"
#}

#resource "citrixadc_servicegroup" "worker-ingress-cluster-1" {
#  servicegroupname = "worker-ingress-cluster-1"
#  servicetype      = "HTTP"
#  lbvservers = [citrixadc_lbvserver.worker-ingress-cluster-1.name]
#  # TODO?
#  #lbmonitor = "${citrixadc_lbmonitor.foo.name}"
#  #servicegroupmembers = ["172.20.0.20:200:50","172.20.0.101:80:10",  "172.20.0.10:80:40"]
#  servicegroupmembers = formatlist(
#    "${local.network_cluster-1}.%d:32000:1",
#    range(local.start_ip_cluster-1 + 5, local.end_ip_cluster-1 + 1)
#  )

#}
