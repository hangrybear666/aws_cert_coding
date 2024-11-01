output "organizational_unit_root_id" {
  value = data.aws_organizations_organization.root_org.roots[0].id
  description = "Root Organization Data"
}

# output "organizational_unit_accounts" {
#   value = data.aws_organizations_organization.root_org.accounts
#   description = "Organization Accounts"
# }

output "organizational_unit_master_account_addr" {
  value = data.aws_organizations_organization.root_org.master_account_email
  description = "Master Account Email Address"
}

output "organizational_units" {
  value = data.aws_organizations_organizational_units.ous.children
}

output "dev_account_id" {
  value = aws_organizations_account.dev_account.id
}
// 577638368192

output "network_account_id" {
  value = aws_organizations_account.network_account.id
}

output "admin_account_id" {
  value = data.aws_caller_identity.admin_account.account_id
}
// 010928217051

output "resource_share_info" {
  value = aws_ram_resource_share.hangrybear_org.arn
}