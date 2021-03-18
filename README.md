# regula-ci-example

[Regula](https://github.com/fugue/regula) is a tool that evaluates CloudFormation and Terraform infrastructure-as-code for potential AWS, Azure, and Google Cloud security misconfigurations and compliance violations prior to deployment. This repo contains examples of using [regula] in CI.

This example is currently set up with the following CI systems:

 -  GitHub Actions: [.github/workflows/main.yml](.github/workflows/main.yml)
 -  Travis: [.travis.yml](.travis.yml)

There is an example of a custom rule for this repository as well --
[example\_custom\_rule/long_description.rego](example\_custom\_rule/long_description.rego).

By passing this directory to regula, it gets included in the report.

## GitHub Action Example

To use Regula to evaluate the Terraform and CloudFormation in your own repository via GitHub Actions, see the instructions below. The GitHub Action itself is here: <https://github.com/fugue/regula-action>

### 1. Customize workflow

In your own repo, create a `.github/workflows` directory and customize your `main.yml` workflow file based on the template in [regula-action](https://github.com/fugue/regula-action#example). You can see this example's configuration in [.github/workflows/main.yml](https://github.com/fugue/regula-ci-example/blob/master/.github/workflows/main.yml).

This example has three jobs:

- `regula_tf_job` demonstrates checking invalid Terraform.
- `regula_cfn_job` demonstrates checking invalid CloudFormation.
- `regula_valid_cfn_job` demonstrates checking valid CloudFormation.

The jobs use the following [inputs](https://github.com/fugue/regula-action#inputs):

**regula_tf_job**
- `input_path` is set to `infra_tf`, where [main.tf](https://github.com/fugue/regula-ci-example/blob/master/infra_tf/main.tf) lives.
- `rego_paths` is set to `/opt/regula/rules example_custom_rule`, which includes the default Regula rules in addition to the rule in the [`example_custom_rule`](https://github.com/fugue/regula-ci-example/tree/master/example_custom_rule) folder. If you want to specify additional directories, you could do so with something like `/opt/regula/rules example_custom_rule company_policy_rules`.
- See our note about environment variables [here](https://github.com/fugue/regula-action#environment-variables). You can read GitHub's documentation [here](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets) about securely configuring the action to use your own AWS access key ID and secret access key.

**regula_cfn_job**
- `input_path` is set to [`infra_cfn/cloudformation.yaml`](https://github.com/fugue/regula-ci-example/blob/master/infra_cfn/cloudformation.yaml)
- `rego_paths` is set to `/opt/regula/rules`

**regula_valid_cfn_job**
- `input_path` is set to [`infra_valid_cfn/cloudformation.yaml`](https://github.com/fugue/regula-ci-example/blob/master/infra_valid_cfn/cloudformation.yaml)
- `rego_paths` is set to `/opt/regula/rules`

If you'd like to further customize your action, check out GitHub's docs for [configuring a workflow](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/configuring-a-workflow).

When you're done, push your changes. Now, the action will run every time you push to the repo. (Unless you've configured your action with a different trigger, of course!) For more information about GitHub Actions, see the [docs](https://help.github.com/en/actions).

### 2. Test it out!

Commit a Terraform file, Terraform JSON plan, or CloudFormation template to the repository (and make sure they are where you specified in your `main.yml`!). In this case, that's the following:

- [`infra_tf/main.tf`](https://github.com/fugue/regula-ci-example/blob/master/infra_tf/main.tf)
- [`infra_cfn/cloudformation.yaml`](https://github.com/fugue/regula-ci-example/blob/master/infra_cfn/cloudformation.yaml)
- [`infra_valid_cfn/cloudformation.yaml`](https://github.com/fugue/regula-ci-example/blob/master/infra_valid_cfn/cloudformation.yaml)

The action will run automatically, and you can view the Regula test results in the Actions tab of your repo.

### Understanding the test results

If you look at the GitHub Action logs, you'll see the report for each job.

#### Invalid Terraform results

Here's a shortened version of our example **Regula Terraform job**, which failed the compliance check:

```
{
  "result": [
    {
      "expressions": [
        {
          "value": {
            "controls": {
              "CIS_1-22": {
                "rules": [
                  "iam_admin_policy"
                ],
                "valid": false
                ...
              },
            },
            "rules": {
              "iam_admin_policy": {
                "metadata": {
                  "custom": {
                    "controls": {
                      "CIS": [
                        "CIS_1-22"
                      ]
                    },
                    "severity": "High"
                  },
                  "description": "IAM policies should not have full \"*:*\" administrative privileges. IAM policies should start with a minimum set of permissions and include more as needed rather than starting with full administrative privileges. Providing full administrative privileges when unnecessary exposes resources to potentially unwanted actions.",
                  "id": "FG_R00092",
                  "title": "IAM policies should not have full \"*:*\" administrative privileges"
                },
                "resources": {
                  "aws_iam_policy.basically_allow_all": {
                    "id": "aws_iam_policy.basically_allow_all",
                    "message": "",
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
              ...
            },
            "summary": {
              "controls_failed": 1,
              "controls_passed": 29,
              "rules_failed": 2,
              "rules_passed": 22,
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
22 rules passed, 2 rules failed
29 controls passed, 1 controls failed
Rule iam_admin_policy failed for resource aws_iam_policy.basically_allow_all
Rule long_description failed for resource aws_iam_policy.basically_allow_all
```

The bit at the end is the most important part -- it's a breakdown of the compliance state of your infrastructure-as-code. In this case, the test failed. This is great, because now we know there's a policy violation in our Terraform! (You'll also see this information in the `summary` block of the output.)

Dig a little deeper and you'll see exactly which resources violated which controls or rules. (For an explanation of the difference between controls and rules, see the [Regula README](https://github.com/fugue/regula/blob/master/README.md#compliance-controls-vs-rules).)

Above, in the `controls` block, you can see that the Terraform in this example is noncompliant with `CIS_1-22`, and the mapped rules that failed are listed underneath (in this case, `iam_admin_policy`). Here it is again:

```
            "controls": {
              "CIS_1-22": {
                "rules": [
                  "iam_admin_policy"
                ],
                "valid": false
              },
            },
```

In the `rules` block further down, you'll see that the resource `aws_iam_policy.basically_allow_all` was the one that failed the mapped rule -- as noted by `"valid": false`. In contrast, `aws_iam_policy.basically_deny_all` passed.

```
            "rules": {
              "iam_admin_policy": {
                "metadata": {
                  "custom": {
                    "controls": {
                      "CIS": [
                        "CIS_1-22"
                      ]
                    },
                    "severity": "High"
                  },
                  "description": "IAM policies should not have full \"*:*\" administrative privileges. IAM policies should start with a minimum set of permissions and include more as needed rather than starting with full administrative privileges. Providing full administrative privileges when unnecessary exposes resources to potentially unwanted actions.",
                  "id": "FG_R00092",
                  "title": "IAM policies should not have full \"*:*\" administrative privileges"
                },
                "resources": {
                  "aws_iam_policy.basically_allow_all": {
                    "id": "aws_iam_policy.basically_allow_all",
                    "message": "",
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
              "long_description": {
                "metadata": {},
                "resources": {
                  "aws_iam_policy.basically_allow_all": {
                    "id": "aws_iam_policy.basically_allow_all",
                    "message": "",
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

#### Invalid CloudFormation results

The output for our example **Regula CloudFormation** job is very similar, as our CloudFormation template passed most of the CloudFormation rules, but failed two. Here's the output at the very end of the job log:

```
19 rules passed, 2 rules failed
20 controls passed, 15 controls failed
Rule cfn_iam_admin_policy failed for resource InvalidPolicy02
Rule cfn_iam_admin_policy failed for resource InvalidPolicy03
Rule cfn_iam_admin_policy failed for resource InvalidPolicy01
Rule cfn_iam_admin_policy failed for resource InvalidRole01
Rule cfn_iam_admin_policy failed for resource InvalidUser01
Rule cfn_iam_admin_policy failed for resource InvalidGroup01
Rule cfn_iam_policy failed for resource InvalidUser01
```

#### Valid CloudFormation results

The output for our example **Regula Valid CloudFormation** job is similar as well, but in this case, our CloudFormation template _passed_ all rules. Again, here's the output at the end of the log:

```
21 rules and 35 controls passed!
```

## Further Reading
For more information about Regula and how to use it, check out these resources:

- [Regula](https://github.com/fugue/regula)
- [Regula GitHub Action](https://github.com/fugue/regula-action)
- [fregot](https://github.com/fugue/fregot)
- [OPA](https://www.openpolicyagent.org/)

[regula]: https://github.com/fugue/regula
