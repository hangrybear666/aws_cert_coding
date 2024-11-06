# Applies to all accounts / OUs in the org except the management account OR IAM users within the mgtm account
data "aws_iam_policy_document" "restrict_regions" {
  statement {
    sid       = "RegionRestriction"
    effect    = "Deny"
    not_actions   = [ "organizations:*",
                      "iam:*",
                      "budget:*"
                    ]
    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"

      values = [
        "eu-central-1"
      ]
    }
  }
}

resource "aws_organizations_policy" "restrict_regions" {
  name        = "restrict_regions"
  description = "Deny all regions except EU central 1"
  content     = data.aws_iam_policy_document.restrict_regions.json
}

resource "aws_organizations_policy_attachment" "restrict_regions_on_root" {
  policy_id = aws_organizations_policy.restrict_regions.id
  target_id = data.aws_organizations_organization.root_org.roots[0].id
}

# Applies to all accounts / OUs in the org except the management account OR IAM users within the mgtm account
data "aws_iam_policy_document" "restrict_ec2_types" {
  statement {
    sid       = "RestrictEc2Types"
    effect    = "Deny"
    actions   = ["ec2:RunInstances"]
    resources = ["arn:aws:ec2:*:*:instance/*"]

    condition {
      test     = "StringNotEquals"
      variable = "ec2:InstanceType"

      values = [
        "t3*",
        "t2*",
      ]
    }
  }
}

resource "aws_organizations_policy" "restrict_ec2_types" {
  name        = "restrict_ec2_types"
  description = "Allow cheap EC2 instance types only."
  content     = data.aws_iam_policy_document.restrict_ec2_types.json
}

resource "aws_organizations_policy_attachment" "restrict_ec2_types_on_root" {
  policy_id = aws_organizations_policy.restrict_ec2_types.id
  target_id = data.aws_organizations_organization.root_org.roots[0].id
}
