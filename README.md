# regula-ci-example

[Regula](https://github.com/fugue/regula) is a tool that evaluates Terraform infrastructure-as-code for potential security misconfigurations and compliance violations prior to deployment. This repo contains examples of using [regula] in CI.

This example is currently set up with the following CI systems:

 -  GitHub Actions: [.github/workflows/main.yml](.github/workflows/main.yml)
 -  Travis: [.travis.yml](.travis.yml)

There is an example of a custom rule for this repository as well --
[example\_custom\_rule/long_description.rego](example\_custom\_rule/long_description.rego).

By passing this directory to regula, it gets included in the report.

## GitHub Action Example

To use Regula to evaluate the Terraform in your own repository via GitHub Actions, see the instructions below. The GitHub Action itself is here: <https://github.com/fugue/regula-action>

### 1. Customize workflow

In your own repo, create a `.github/workflows` directory and customize your `main.yml` workflow file based on the template in [regula-action](https://github.com/fugue/regula-action#example). You can see this example's configuration in [.github/workflows/main.yml](https://github.com/fugue/regula-ci-example/blob/master/.github/workflows/main.yml).

This example uses the following [inputs](https://github.com/fugue/regula-action#inputs):
- `terraform_directory` is set to `.`, where [main.tf](https://github.com/fugue/regula-ci-example/blob/master/main.tf) lives (in the repo root).
- `rego_paths` is set to `/opt/regula/rules example_custom_rule`, which includes the default Regula rules in addition to the rule in the [`example_custom_rule`](https://github.com/fugue/regula-ci-example/tree/master/example_custom_rule) folder. If you want to specify additional directories, you could do so with something like `/opt/regula/rules example_custom_rule company_policy_rules`.

See our note about environment variables [here](https://github.com/fugue/regula-action#environment-variables). You can read GitHub's documentation [here](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets) about configuring the action to use your own AWS access key ID and secret access key.

If you'd like to further customize your action, check out GitHub's docs for [configuring a workflow](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/configuring-a-workflow).

When you're done, push your changes. Now, the action will run every time you push to the repo. (Unless you've configured your action with a different trigger, of course!) For more information about GitHub Actions, see the [docs](https://help.github.com/en/actions).

### 2. Test it out!

Commit a Terraform file to the repository (and make sure it's in the directory you specified in your `main.yml`!). In this case, that's [main.tf](https://github.com/fugue/regula-ci-example/blob/master/main.tf).

The action will run automatically, and you can view the Regula test results in the Actions tab of your repo. For example, see how the Terraform in our example failed the [Regula check here](https://github.com/fugue/regula-ci-example/runs/389223751). That's because [one of the IAM policies](https://github.com/fugue/regula-ci-example/blob/master/main.tf#L6-L9) violated the Rego policy by having a description shorter than 25 characters.

### Understanding the test results

If you look at the [Regula portion of the logs](https://github.com/fugue/regula-ci-example/runs/389223751#step:4:12), you'll see the report, which looks like this (though we shortened it here):

```
{
  "result": [
    {
      "expressions": [
        {
          "value": {
            "controls": {
              "CIS_1-16": {
                "rules": [
                  "iam_user_attached_policy"
                ],
                "valid": true
                ...
              },
            },
            "rules": {
              "cloudtrail_log_file_validation": {
                "resources": {},
                "valid": true
              },
              ...
            },
            "summary": {
              "controls_failed": 2,
              "controls_passed": 12,
              "rules_failed": 2,
              "rules_passed": 8,
              "valid": false
            }
          },
          "text": "data.fugue.regula.report",
          "location": {
            "row": 1,
            "col": 1
          }
        }
      ]
    }
  ]
}
8 rules passed, 2 rules failed
12 controls passed, 2 controls failed
##[error] 2 rules failed
##[error]Docker run failed with exit code 1
```

The bit at the end is the most important part -- it's a breakdown of the compliance state of your Terraform files. In this case, the test failed. This is great, because now we know there's a policy violation in our Terraform! (You'll also see this information in the `summary` block of the output.)

Dig a little deeper and you'll see exactly which resources violated which controls or rules. (For an explanation of the difference between controls and rules, see the [Regula README](https://github.com/fugue/regula/blob/master/README.md#compliance-controls-vs-rules).)

Below, in the `controls` block, you can see that the Terraform in this example is noncompliant with `CIS_1-22`, and the mapped rules that failed are listed underneath (in this case, `iam_admin_policy`).

In the `rules` block further down, you'll see that the resource `aws_iam_policy.basically_allow_all` was the one that failed the mapped rule -- as noted by `"valid": false`. In contrast, `aws_iam_policy.basically_deny_all` passed.

```
            "controls": {
              "CIS_1-22": {
                "rules": [
                  "iam_admin_policy"
                ],
                "valid": false
              },
            },
            ...
            "rules": {
              "iam_admin_policy": {
                "resources": {
                  "aws_iam_policy.basically_allow_all": {
                    "id": "aws_iam_policy.basically_allow_all",
                    "message": "invalid",
                    "type": "aws_iam_policy",
                    "valid": false
                  },
                  "aws_iam_policy.basically_deny_all": {
                    "id": "aws_iam_policy.basically_deny_all",
                    "message": "",
                    "type": "aws_iam_policy",
                    "valid": true
                  }
                },
                "valid": false
              },
```

The resource `aws_iam_policy.basically_allow_all` _also_ failed the custom rule [long\_description](https://github.com/fugue/regula-ci-example/blob/master/example_custom_rule/long_description.rego):

```
            "rules": {
              ...
              "long_description": {
                "resources": {
                  "aws_iam_policy.basically_allow_all": {
                    "id": "aws_iam_policy.basically_allow_all",
                    "message": "invalid",
                    "type": "aws_iam_policy",
                    "valid": false
                  },
                  "aws_iam_policy.basically_deny_all": {
                    "id": "aws_iam_policy.basically_deny_all",
                    "message": "",
                    "type": "aws_iam_policy",
                    "valid": true
                  }
                },
                "valid": false
              },
```

## Further Reading
For more information about Regula and how to use it, check out these resources:

- [Regula](https://github.com/fugue/regula)
- [Regula GitHub Action](https://github.com/fugue/regula-action)
- [fregot](https://github.com/fugue/fregot)
- [OPA](https://www.openpolicyagent.org/)

[regula]: https://github.com/fugue/regula
