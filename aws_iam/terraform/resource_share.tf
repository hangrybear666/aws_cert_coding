resource "aws_ram_resource_share" "hangrybear_org" {
  name                      = "hangrybear_org_resource_share"
  allow_external_principals = false
}

resource "aws_ram_resource_association" "dev_subnets_ram_associations" {
  for_each = data.aws_subnet.dev_subnet_collection
  resource_share_arn = aws_ram_resource_share.hangrybear_org.arn
  resource_arn       = each.value.arn
}

resource "aws_ram_principal_association" "dev_account_ram_association" {
  principal          = aws_organizations_account.dev_account.id
  resource_share_arn = aws_ram_resource_share.hangrybear_org.arn
}