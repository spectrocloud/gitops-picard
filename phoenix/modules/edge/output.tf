output "kubeconfig" {
  value = spectrocloud_cluster_edge_native.this.kubeconfig
}

# output "sa_crt_pem" {
#   value = data.local_file.pem_file.content
# }
