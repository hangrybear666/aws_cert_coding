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

