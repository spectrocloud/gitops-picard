# Discovery Terraform Codebase Architecture

This document provides a comprehensive overview of the Terraform resources, providers, and architecture used in the Discovery infrastructure.

---

## Providers

| Provider | Version | Purpose |
|----------|---------|---------|
| **spectrocloud** | `0.14.0` | Manage Kubernetes clusters via Spectro Cloud Palette |
| **vault** | `~> 2.18.0` | Store secrets (kubeconfig, certs, SSH keys) |
| **citrixadc** | `~> 0.12.44` | Configure NetScaler load balancers |
| **tls** | `3.4.0` | Generate SSH keys and TLS certificates |
| **kubernetes** | (implicit) | Read secrets from created clusters |
| **random** | (implicit) | Generate etcd encryption keys |

---

## Data Sources (Lookups)

### Spectro Cloud Provider

| Resource | Purpose |
|----------|---------|
| `data.spectrocloud_cloudaccount_vsphere.default` | Lookup vSphere cloud account by name (`tmpadmin`) |
| `data.spectrocloud_pack.vault` | Lookup Vault pack (v0.17.1) |
| `data.spectrocloud_pack.cni-vsphere` | Lookup Cilium CNI pack (v1.12.6) |
| `data.spectrocloud_pack.k8s-vsphere` | Lookup Kubernetes pack (v1.23.9) |
| `data.spectrocloud_pack.dex` | Lookup Dex authentication pack (v2.35.1) |
| `data.spectrocloud_pack.csi-vsphere` | Lookup vSphere CSI pack (v2.6.0) |
| `data.spectrocloud_pack.ubuntu-vsphere` | Lookup Ubuntu OS pack (v20.04) |
| `data.spectrocloud_pack.vault-stg` | Lookup Vault pack for staging |
| `data.spectrocloud_pack.nginx-stg` | Lookup NGINX pack for staging |
| `data.spectrocloud_pack.cni-vsphere-stg` | Lookup CNI for staging |
| `data.spectrocloud_pack.k8s-vsphere-stg` | Lookup K8s for staging |
| `data.spectrocloud_pack.os-vsphere-stg` | Lookup OS for staging |
| `data.spectrocloud_pack.cilium-tetragon` | Lookup Tetragon security pack |

### Kubernetes Provider (in module)

| Resource | Purpose |
|----------|---------|
| `data.kubernetes_secret.etcd-ca` | Read etcd CA certificate from cluster |

---

## Resources Created & Managed

### 1. Spectro Cloud Provider

#### Cluster Profiles

| Resource | Name | Description |
|----------|------|-------------|
| `spectrocloud_cluster_profile.sc-npe` | `sc-npe` | Production cluster profile with Ubuntu, K8s 1.23.9, Cilium, vSphere CSI, Vault, Dex |
| `spectrocloud_cluster_profile.sc-npe-stg` | `sc-npe-stg` | Staging cluster profile with additional NGINX, Tetragon |

**Cluster Profile Packs:**

| Pack | Version | Purpose |
|------|---------|---------|
| `ubuntu-vsphere` | 20.04 | Operating System |
| `kubernetes` | 1.23.9 / 1.24.13 | Kubernetes distribution |
| `cni-cilium-oss` | 1.12.6 | Container Network Interface |
| `csi-vsphere-csi` | 2.6.x | Container Storage Interface |
| `vault` | 0.17.1 | Secrets management |
| `dex` | 2.35.1 | OIDC authentication |
| `nginx` | 1.2.1 | Ingress controller (staging only) |
| `tetragon` | 0.8.3 | Security observability (staging only) |

#### Clusters (via Module)

| Resource | Description |
|----------|-------------|
| `spectrocloud_cluster_vsphere.this` | vSphere Kubernetes cluster with control plane and worker pools |

#### IP Pools (via Module)

| Resource | Description |
|----------|-------------|
| `spectrocloud_privatecloudgateway_ippool.api` | IP pool for control plane nodes |
| `spectrocloud_privatecloudgateway_ippool.workers` | IP pool for worker nodes |
| `spectrocloud_privatecloudgateway_ippool.workers1` | Optional 2nd IP pool for additional workers |

---

### 2. Vault Provider (in Module)

| Resource | Path Pattern | Purpose |
|----------|--------------|---------|
| `vault_generic_secret.kubeconfig` | `secret/sc/discovery/kubeconfig/<cluster>` | Store cluster kubeconfig |
| `vault_generic_secret.etcd_encryption_key` | `secret/sc/discovery/etcd-certs/<cluster>_encryption_key` | Store etcd encryption key |
| `vault_generic_secret.etcd_certs` | `secret/sc/discovery/etcd-certs/<cluster>_certs` | Store etcd CA cert, healthcheck client cert/key |
| `vault_generic_secret.ssh_keys` | `secret/sc/discovery/ssh-keys/<cluster>` | Store SSH private/public keys |

---

### 3. Citrix ADC / NetScaler Provider (in Module)

> **Note**: NetScaler resources are conditionally created based on VIP variables being set.

#### API/Control Plane Load Balancing

| Resource | Description |
|----------|-------------|
| `citrixadc_lbvserver.api` | LB virtual server for K8s API (port 8443) |
| `citrixadc_servicegroup.api` | Service group with CP nodes on port 6443 |

#### NodePort Load Balancing

| Resource | Description |
|----------|-------------|
| `citrixadc_lbvserver.nodeport` | LB virtual server for NodePort services (port 65535) |
| `citrixadc_servicegroup.nodeport` | Service group with worker nodes |

#### Ingress Load Balancing

| Resource | Description |
|----------|-------------|
| `citrixadc_lbvserver.ingress` | LB virtual server for ingress (port 443, with proxy protocol) |
| `citrixadc_servicegroup.ingress` | Service group with workers on port 30000 |

---

### 4. TLS Provider (in Module)

| Resource | Purpose |
|----------|---------|
| `tls_private_key.ssh_key` | Generate SSH key pair for cluster nodes |
| `tls_private_key.etcd-healthcheck` | Generate private key for etcd healthcheck client |
| `tls_cert_request.etcd-healthcheck` | Create CSR for etcd healthcheck client cert |
| `tls_locally_signed_cert.etcd-healthcheck` | Sign etcd healthcheck client cert (4-year validity) |

---

### 5. Random Provider (in Module)

| Resource | Purpose |
|----------|---------|
| `random_id.etcd_encryption_key` | Generate 32-byte etcd encryption key |

---

## Module Instances

| Module Instance | Cluster Name | Profile | Network | API IPs | Worker IPs |
|-----------------|--------------|---------|---------|---------|------------|
| `module.sc-npe-1700` | `sc-npe-1700` | `sc-npe-stg` | `10.10.184.x` | 110-114 | 115-124 |
| `module.sc-npe-1701` | `sc-npe-1701` | `sc-npe` | `10.10.184.x` | 130-134 | 135-144 |

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           DISCOVERY TERRAFORM ARCHITECTURE                       │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                           ROOT MODULE                                    │   │
│   │                                                                          │   │
│   │   ┌──────────────────────┐       ┌──────────────────────┐               │   │
│   │   │   Cluster Profiles   │       │    Data Lookups      │               │   │
│   │   │                      │       │                      │               │   │
│   │   │  ┌────────────────┐  │       │  • Cloud Account     │               │   │
│   │   │  │    sc-npe      │  │       │  • Packs:            │               │   │
│   │   │  │  (Production)  │  │       │    - Ubuntu          │               │   │
│   │   │  └────────────────┘  │       │    - Kubernetes      │               │   │
│   │   │  ┌────────────────┐  │       │    - Cilium CNI      │               │   │
│   │   │  │  sc-npe-stg    │  │       │    - vSphere CSI     │               │   │
│   │   │  │   (Staging)    │  │       │    - Vault           │               │   │
│   │   │  └────────────────┘  │       │    - Dex             │               │   │
│   │   └──────────┬───────────┘       │    - NGINX           │               │   │
│   │              │                   │    - Tetragon        │               │   │
│   │              │                   └──────────┬───────────┘               │   │
│   └──────────────┼──────────────────────────────┼───────────────────────────┘   │
│                  │                              │                                │
│                  └──────────────┬───────────────┘                                │
│                                 │                                                │
│                                 ▼                                                │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                      TKE-CLUSTER MODULE                                  │   │
│   │                                                                          │   │
│   │   ┌─────────────────────────────────────────────────────────────────┐   │   │
│   │   │                    SPECTRO CLOUD RESOURCES                       │   │   │
│   │   │                                                                  │   │   │
│   │   │   ┌─────────────────┐         ┌─────────────────────────────┐   │   │   │
│   │   │   │    IP Pools     │         │      vSphere Cluster        │   │   │   │
│   │   │   │                 │         │                             │   │   │   │
│   │   │   │  • API Pool     │────────▶│  • Control Plane Pool       │   │   │   │
│   │   │   │  • Workers Pool │         │    (master-pool)            │   │   │   │
│   │   │   │  • Workers1 Pool│         │                             │   │   │   │
│   │   │   │    (optional)   │         │  • Worker Pools             │   │   │   │
│   │   │   └─────────────────┘         │    (wp-az1, wp-az2, wp-az3) │   │   │   │
│   │   │                               │                             │   │   │   │
│   │   │                               │  • Additional Workers       │   │   │   │
│   │   │                               │    (wp-az1-1, etc.)         │   │   │   │
│   │   │                               └──────────────┬──────────────┘   │   │   │
│   │   └──────────────────────────────────────────────┼──────────────────┘   │   │
│   │                                                  │                      │   │
│   │   ┌──────────────────────────────────────────────┼──────────────────┐   │   │
│   │   │                    TLS RESOURCES             │                  │   │   │
│   │   │                                              ▼                  │   │   │
│   │   │   ┌─────────────────┐         ┌─────────────────────────────┐  │   │   │
│   │   │   │   SSH Keys      │         │     ETCD Certificates       │  │   │   │
│   │   │   │                 │         │                             │  │   │   │
│   │   │   │  • Private Key  │         │  • Healthcheck Private Key  │  │   │   │
│   │   │   │  • Public Key   │         │  • Healthcheck CSR          │  │   │   │
│   │   │   └────────┬────────┘         │  • Healthcheck Signed Cert  │  │   │   │
│   │   │            │                  └──────────────┬──────────────┘  │   │   │
│   │   └────────────┼─────────────────────────────────┼──────────────────┘   │   │
│   │                │                                 │                      │   │
│   │                └─────────────┬───────────────────┘                      │   │
│   │                              │                                          │   │
│   │                              ▼                                          │   │
│   │   ┌─────────────────────────────────────────────────────────────────┐   │   │
│   │   │                      VAULT SECRETS                               │   │   │
│   │   │                                                                  │   │   │
│   │   │   secret/sc/discovery/                                          │   │   │
│   │   │   ├── kubeconfig/<cluster-name>      # Cluster kubeconfig       │   │   │
│   │   │   ├── etcd-certs/<cluster>_encryption_key                       │   │   │
│   │   │   ├── etcd-certs/<cluster>_certs     # CA + healthcheck certs   │   │   │
│   │   │   └── ssh-keys/<cluster-name>        # SSH key pair             │   │   │
│   │   │                                                                  │   │   │
│   │   └─────────────────────────────────────────────────────────────────┘   │   │
│   │                                                                          │   │
│   │   ┌─────────────────────────────────────────────────────────────────┐   │   │
│   │   │               NETSCALER LOAD BALANCERS (Optional)                │   │   │
│   │   │                                                                  │   │   │
│   │   │   ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │   │   │
│   │   │   │   API/CP LB     │  │  NodePort LB    │  │   Ingress LB    │ │   │   │
│   │   │   │                 │  │                 │  │                 │ │   │   │
│   │   │   │  VIP:8443       │  │  VIP:65535      │  │  VIP:443        │ │   │   │
│   │   │   │      ↓          │  │      ↓          │  │      ↓          │ │   │   │
│   │   │   │  CP Nodes:6443  │  │  Workers:65535  │  │  Workers:30000  │ │   │   │
│   │   │   │                 │  │                 │  │  (proxy proto)  │ │   │   │
│   │   │   └─────────────────┘  └─────────────────┘  └─────────────────┘ │   │   │
│   │   │                                                                  │   │   │
│   │   └─────────────────────────────────────────────────────────────────┘   │   │
│   │                                                                          │   │
│   └──────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
└──────────────────────────────────────────────────────────────────────────────────┘
```

---

## Infrastructure Configuration

### Backend Configuration

| Setting | Value |
|---------|-------|
| Type | S3 (MinIO) |
| Bucket | `discovery-tf` |
| Key | `discovery/terraform.tfstate` |
| Endpoint | `http://10.10.184.50:9199` |

### Global Configuration

| Setting | Value |
|---------|-------|
| DNS Domain | `discovery.spectrocloud.com` |
| Datacenter | `Datacenter` |
| Network Prefix | `/18` |
| Network | `VM-NETWORK` |
| Nameservers | `10.10.128.8` |

### vSphere Placements

| Cluster | Resource Pool | Datastore |
|---------|---------------|-----------|
| Cluster1 | `rp-cluster1-palette-pax` | `vsanDatastore1` |
| Cluster2 | `rp-cluster2-palette-pax` | `vsanDatastore2` |
| Cluster3 | `rp-cluster3-palette-pax` | `vsanDatastore3` |

### Node Specifications

| Node Type | CPU | Memory | Disk |
|-----------|-----|--------|------|
| Control Plane | 4 | 8192 MB | 60 GB |
| Worker | 4 | 8192 MB | 60 GB |

---

## File Structure

```
discovery/
├── main.tf                    # Backend config, locals, global config
├── providers.tf               # Provider configurations
├── variables.tf               # Variable definitions
├── clusterprofile.tf          # Production cluster profile (sc-npe)
├── clusterprofile-stg.tf      # Staging cluster profile (sc-npe-stg)
├── sc-npe-1700.tf             # Cluster instance using staging profile
├── sc-npe-1701.tf             # Cluster instance using production profile
├── terraform.tfvars           # Variable values
├── terraform.template.tfvars  # Template for tfvars
├── config/                    # Production pack configurations
│   ├── dex.yaml
│   ├── k8s.yaml
│   ├── namespace-labeler.yaml
│   ├── os_ubuntu.yaml
│   └── vault-dex.yaml
├── config-stg/                # Staging pack configurations
│   ├── certs/
│   │   ├── ca.crt
│   │   ├── sc-npe.crt
│   │   └── sc-npe.key
│   ├── dex.yaml
│   ├── k8s.yaml
│   ├── namespace-labeler.yaml
│   ├── nginx.yaml
│   ├── nginx-config.yaml
│   ├── os_ubuntu.yaml
│   └── vault-dex.yaml
└── modules/
    └── tke-cluster/           # Reusable cluster module
        ├── cluster.tf         # Cluster resource definition
        ├── etcd_certs.tf      # ETCD certificate generation
        ├── ippool.tf          # IP pool resources
        ├── kubernetes.tf      # Kubernetes provider config
        ├── netscaler.tf       # NetScaler LB resources
        ├── providers.tf       # Module provider requirements
        ├── variables.tf       # Module variables
        └── vault.tf           # Vault secret storage
```

---

## Usage

### Initialize Terraform

```bash
terraform init \
  -backend-config="access_key=<ACCESS_KEY>" \
  -backend-config="secret_key=<SECRET_KEY>"
```

### Plan Changes

```bash
terraform plan -var-file=terraform.tfvars
```

### Apply Changes

```bash
terraform apply -var-file=terraform.tfvars
```

### Target Specific Resources

```bash
# Apply only a specific cluster
terraform apply -target=module.sc-npe-1700

# Apply only cluster profiles
terraform apply -target=spectrocloud_cluster_profile.sc-npe
```

---

## Outputs

The module provides the following outputs:

| Output | Description |
|--------|-------------|
| `cluster-ca-cert` | Cluster CA certificate (sensitive) |
| `cluster-client-cert` | Cluster client certificate (sensitive) |
| `cluster-client-key` | Cluster client key (sensitive) |

