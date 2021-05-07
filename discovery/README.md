# Cluster Provisioning

Spectro Cloud Terraform module to help provision K8aaS use-cases.

## Module

- Provisions Spectro Cloud VMware clusters
- Create IP Pool (1 for API, 1 for Workers)
- Creates new ETCD encryption key per cluster
- Uploads Kubeconfig and ETCD encryption key to Vault
- Generates etcd healthclient certificate and stores to vault
- Creates 3 netscaler service groups (API, Nodeport, and Ingress)


## Config

### terraform.tfvars:

1. Copy `terraform.template.tfvars` to `terraform.tfvars`.
2. Specify all values in `terraform.tfvars`.

### config/

Look through all the config in `config/` directory. Modify all as needed.

### main.tf

Specify all values.

## Initialize

```
terraform init \
  -upgrade \
  -backend-config="access_key=access" \
  -backend-config="secret_key=key"
```

