# Provider for the Dev Account, assuming role from the Management Account
provider "aws" {
  alias  = "dev_account"
  region = "eu-central-1"

  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.dev_account.id}:role/OrganizationAccountAccessRole"
  }
}
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

resource "aws_iam_role_policy_attachment" "ec2_access_policy_attachment" {
  role       = aws_iam_role.ec2_full_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

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


# # Attach AmazonEC2FullAccess Policy in the Dev Account
# resource "aws_iam_role" "dev_ec2_full_access_role" {
#   provider           = aws.dev_account
#   name               = "DevAccountEC2FullAccessRole"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "arn:aws:iam::${data.aws_caller_identity.admin_account.account_id}:root"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "dev_account_ec2_full_access_attachment" {
#   provider   = aws.dev_account
#   role       = aws_iam_role.dev_ec2_full_access_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
# }

# # Outputs for reference
# output "dev_role_arn" {
#   value = aws_iam_role.dev_ec2_full_access_role.arn
# }

# # IAM Role in Admin Account
# resource "aws_iam_role" "dev_access_to_admin_ec2" {
#   name = "DevAccessToAdminEC2"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "arn:aws:iam::${aws_organizations_account.dev_account.id}:root"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

# # Attach Policies to Access EC2 Instances in the Admin Account
# resource "aws_iam_role_policy" "dev_access_ec2_policy" {
#   role = aws_iam_role.dev_access_to_admin_ec2.name

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "ec2:DescribeInstances",
#         "ec2:StartInstances",
#         "ec2:StopInstances",
#         "ec2:TerminateInstances"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }
