
resource "aws_organizations_account" "dev_account" {
  name  = "hangrybear_dev"
  email = "hangrybear_dev1@protonmail.com"
  parent_id = aws_organizations_organizational_unit.development.id
  role_name = "OrganizationAccountAccessRole" # AWS default role to access member account from management account
  # close_on_deletion = true
  iam_user_access_to_billing = "ALLOW"
}

# Create an IAM user with console access in the new account
resource "aws_iam_user" "dev_account_user" {
  provider = aws.dev_account
  name     = "hangrybear_dev"
  force_destroy = true
}

# Attach an IAM policy to allow console login and necessary permissions
resource "aws_iam_user_policy_attachment" "dev_account_user_policy" {
  provider   = aws.dev_account
  user       = aws_iam_user.dev_account_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create a login profile for console access
resource "aws_iam_user_login_profile" "dev_account_user_profile" {
  provider    = aws.dev_account
  user        = aws_iam_user.dev_account_user.name
  password_reset_required = false
}

# resource "aws_organizations_account" "network_account" {
#   name  = "hangrybear_network"
#   email = "hangrybear_net@protonmail.com"
#   parent_id = aws_organizations_organizational_unit.network.id
#   role_name = "OrganizationAccountAccessRole" # AWS default role to access member account from management account
#   # close_on_deletion = true
#   iam_user_access_to_billing = "ALLOW"
# }