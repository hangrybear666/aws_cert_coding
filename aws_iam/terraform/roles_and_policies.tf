# Provider for the Dev Account, assuming role from the Management Account
provider "aws" {
  alias  = "dev_account"
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.dev_account.id}:role/OrganizationAccountAccessRole"
  }
}

# create role with dev account added as trusted principal
resource "aws_iam_role" "ec2_full_access_role" {
  name = "EC2FullAccessRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${aws_organizations_account.dev_account.id}:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# assign ec2 full access policy to EC2FullAccessRole
resource "aws_iam_role_policy_attachment" "ec2_access_policy_attachment" {
  role       = aws_iam_role.ec2_full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# create a STS AssumeRole policy for dev account so it can assume the EC2FullAccessRole in Admin account
resource "aws_iam_role" "cross_account_ec2_access" {
  provider = aws.dev_account
  name = "CrossAccountEC2Access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.admin_account.account_id}:role/EC2FullAccessRole"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}