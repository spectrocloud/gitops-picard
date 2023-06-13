locals {
  bsl_files = fileset("${path.module}/config", "backup-storage-location-s3-*.yaml")
  bsls = {
    for k in local.bsl_files :
    trimsuffix(k, ".yaml") => yamldecode(file("config/${k}"))
  }

  bsl_ids = {
    for k, v in spectrocloud_backup_storage_location.this :
    v.name => v.id
  }

  # rbac_yaml    = yamldecode(file("rbac.yaml"))
  # rbac_all_crb = lookup(local.rbac_yaml.all_accounts, "accountRoleBindings", [])
  # rbac_all_rb  = lookup(local.rbac_yaml.all_accounts, "namespaces", [])
  # rbac_map = {
  #   for k, v in local.rbac_yaml.accounts :
  #   k => {
  #     accountRoleBindings = concat(local.rbac_all_crb, lookup(v, "accountRoleBindings", []))
  #     namespaces        = concat(local.rbac_all_rb, lookup(v, "namespaces", []))
  #   }
  # }
}

################################  accounts   ####################################################

# Create the backup storage location
resource "spectrocloud_backup_storage_location" "this" {
  for_each = local.bsls

  name        = each.value.name
  is_default  = false
  region      = each.value.region
  bucket_name = each.value.bucket_name
  s3 {
    credential_type = "sts"
    arn             = each.value.arn
    external_id     = each.value.external_id
  }
}