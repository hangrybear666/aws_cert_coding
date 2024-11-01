resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "sandbox"
  parent_id = data.aws_organizations_organization.root_org.roots[0].id
}

resource "aws_organizations_organizational_unit" "tempdelete" {
  name      = "tempdelete"
  parent_id = aws_organizations_organizational_unit.sandbox.id
}

resource "aws_organizations_organizational_unit" "development" {
  name      = "development"
  parent_id = data.aws_organizations_organization.root_org.roots[0].id
}

resource "aws_organizations_organizational_unit" "network" {
  name      = "network"
  parent_id = data.aws_organizations_organization.root_org.roots[0].id
}

resource "aws_organizations_organizational_unit" "production" {
  name      = "production"
  parent_id = data.aws_organizations_organization.root_org.roots[0].id
}

resource "aws_organizations_account" "dev_account" {
  name  = "hangrybear_dev"
  email = "hangrybear_dev@protonmail.com"
  parent_id = aws_organizations_organizational_unit.development.id
  role_name = "OrganizationAccountAccessRole" # AWS default role to access member account from management account
  close_on_deletion = true
  iam_user_access_to_billing = "ALLOW"
}

resource "aws_organizations_account" "network_account" {
  name  = "hangrybear_network"
  email = "hangrybear_network@protonmail.com"
  parent_id = aws_organizations_organizational_unit.network.id
  role_name = "OrganizationAccountAccessRole" # AWS default role to access member account from management account
  close_on_deletion = true
  iam_user_access_to_billing = "ALLOW"
}


