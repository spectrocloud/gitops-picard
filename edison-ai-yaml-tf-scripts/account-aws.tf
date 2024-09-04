locals {
  account_files = fileset("${path.module}/config", "account-aws-*.yaml")
  accounts = {
    for k in local.account_files :
    trimsuffix(k, ".yaml") => yamldecode(file("config/${k}"))
  }

  # TODO refactor to separate file
  account_ids = merge({
    aws-stage-picard = "60972a2f3b53444f87f22e25"
    }, {
    for k, v in spectrocloud_cloudaccount_aws.this :
    v.name => v.id
  })

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

# Create the VMware account
resource "spectrocloud_cloudaccount_aws" "this" {
  for_each = local.accounts

  type        = "sts"
  name        = each.value.name
  arn         = each.value.arn
  external_id = each.value.external_id
}
