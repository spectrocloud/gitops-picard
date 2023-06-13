# Cluster Provisioning

Spectro Cloud Terraform module to help provision K8aaS use-cases.

## Module

- Provisions Spectro Cloud EKS cluster
- 


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

