data "aws_organizations_organization" "root_org" {}

data "aws_organizations_organizational_units" "ous" {
  parent_id = data.aws_organizations_organization.root_org.roots[0].id
  depends_on = [
    aws_organizations_organizational_unit.sandbox,
    aws_organizations_organizational_unit.tempdelete,
    aws_organizations_organizational_unit.development,
    aws_organizations_organizational_unit.production
  ]
}

data "aws_caller_identity" "admin_account" {}

data "aws_vpc" "dev_vpc" {
  filter {
    name   = "tag:Name"
    values = ["dev-vpc"]
  }
}

data "aws_subnets" "dev_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.dev_vpc.id]
  }
}

data "aws_subnet" "dev_subnet_collection" {
  for_each = toset(data.aws_subnets.dev_subnets.ids)
  id       = each.key
}