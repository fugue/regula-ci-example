provider "aws" {
  version = "~> 2.41"
  region  = "us-west-2"
}

resource "aws_iam_policy" "basically_allow_all" {
  name        = "some_policy"
  path        = "/"
  description = "Some policy with okay we're gonna give this a long description as well"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "basically_deny_all" {
  name        = "some_policy"
  path        = "/"
  description = "Some policy with a long description that denies anything"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Deny",
      "Resource": "*"
    }
  ]
}
EOF
}
