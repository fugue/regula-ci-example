# Policies must have description of at least 25 characters.
package rules.long_description

resource_type = "aws_iam_policy"

default allow = false

allow {
  count(input.description) >= 25
}
