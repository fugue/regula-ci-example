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

This example has 5 jobs:

- `regula_tf_job` demonstrates checking invalid Terraform.
- `regula_cfn_job` demonstrates checking invalid CloudFormation.
- `regula_valid_cfn_job` demonstrates checking valid CloudFormation.
- `regula_multi_cfn_job` demonstrates checking multiple CloudFormation templates (valid and invalid).
- `regula_input_list_job` demonstrates checking CloudFormation _and_ Terraform (valid and invalid).

The jobs use the following [inputs](https://github.com/fugue/regula-action#inputs):

**regula_tf_job**
- `input_path` is set to `infra_tf`, where [main.tf](https://github.com/fugue/regula-ci-example/blob/master/infra_tf/main.tf) lives.
- `rego_paths` is set to the example rule in the [`example_custom_rule`](https://github.com/fugue/regula-ci-example/tree/master/example_custom_rule) folder. If you want to specify additional directories, you could do so with something like `example_custom_rule company_policy_rules`.

**regula_cfn_job**
- `input_path` is set to [`infra_cfn/cloudformation.yaml`](https://github.com/fugue/regula-ci-example/blob/master/infra_cfn/cloudformation.yaml)

**regula_valid_cfn_job**
- `input_path` is set to [`infra_valid_cfn/cloudformation.yaml`](https://github.com/fugue/regula-ci-example/blob/master/infra_valid_cfn/cloudformation.yaml)

**regula_multi_cfn_job**
- `input_path` is set to `'*/cloudformation.yaml'`, which includes both CloudFormation templates listed above

**regula_input_list_job**
- `input_path` is set to both CloudFormation templates _and_ the Terraform directory

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

#### Results - invalid Terraform

Here's the output of our example **Regula Terraform job**, which failed the compliance check:

```
{
  "rule_results": [
    {
      "controls": [
        "CORPORATE-POLICY_1.1"
      ],
      "filepath": "infra_tf/main.tf",
      "input_type": "tf",
      "provider": "aws",
      "resource_id": "aws_iam_policy.basically_allow_all",
      "resource_type": "aws_iam_policy",
      "rule_description": "Per company policy, it is required for all IAM policies to have a description of at least 25 characters.",
      "rule_id": "CUSTOM_0001",
      "rule_message": "",
      "rule_name": "long_description",
      "rule_result": "FAIL",
      "rule_severity": "Low",
      "rule_summary": "IAM policies must have a description of at least 25 characters",
      "source_location": [
        {
          "path": "infra_tf/main.tf",
          "line": 6,
          "column": 1
        }
      ]
    },
    {
      "controls": [
        "CORPORATE-POLICY_1.1"
      ],
      "filepath": "infra_tf/main.tf",
      "input_type": "tf",
      "provider": "aws",
      "resource_id": "aws_iam_policy.basically_deny_all",
      "resource_type": "aws_iam_policy",
      "rule_description": "Per company policy, it is required for all IAM policies to have a description of at least 25 characters.",
      "rule_id": "CUSTOM_0001",
      "rule_message": "",
      "rule_name": "long_description",
      "rule_result": "PASS",
      "rule_severity": "Low",
      "rule_summary": "IAM policies must have a description of at least 25 characters",
      "source_location": [
        {
          "path": "infra_tf/main.tf",
          "line": 25,
          "column": 1
        }
      ]
    },
    {
      "controls": [
        "CIS-AWS_v1.2.0_1.22",
        "CIS-AWS_v1.3.0_1.16"
      ],
      "filepath": "infra_tf/main.tf",
      "input_type": "tf",
      "provider": "aws",
      "resource_id": "aws_iam_policy.basically_allow_all",
      "resource_type": "aws_iam_policy",
      "rule_description": "IAM policies should not have full \"*:*\" administrative privileges. IAM policies should start with a minimum set of permissions and include more as needed rather than starting with full administrative privileges. Providing full administrative privileges when unnecessary exposes resources to potentially unwanted actions.",
      "rule_id": "FG_R00092",
      "rule_message": "",
      "rule_name": "tf_aws_iam_admin_policy",
      "rule_result": "FAIL",
      "rule_severity": "High",
      "rule_summary": "IAM policies should not have full \"*:*\" administrative privileges",
      "source_location": [
        {
          "path": "infra_tf/main.tf",
          "line": 6,
          "column": 1
        }
      ]
    },
    {
      "controls": [
        "CIS-AWS_v1.2.0_1.22",
        "CIS-AWS_v1.3.0_1.16"
      ],
      "filepath": "infra_tf/main.tf",
      "input_type": "tf",
      "provider": "aws",
      "resource_id": "aws_iam_policy.basically_deny_all",
      "resource_type": "aws_iam_policy",
      "rule_description": "IAM policies should not have full \"*:*\" administrative privileges. IAM policies should start with a minimum set of permissions and include more as needed rather than starting with full administrative privileges. Providing full administrative privileges when unnecessary exposes resources to potentially unwanted actions.",
      "rule_id": "FG_R00092",
      "rule_message": "",
      "rule_name": "tf_aws_iam_admin_policy",
      "rule_result": "PASS",
      "rule_severity": "High",
      "rule_summary": "IAM policies should not have full \"*:*\" administrative privileges",
      "source_location": [
        {
          "path": "infra_tf/main.tf",
          "line": 25,
          "column": 1
        }
      ]
    },
    {
      "controls": [],
      "filepath": "infra_tf/main.tf",
      "input_type": "tf",
      "provider": "aws",
      "resource_id": "aws_iam_policy.basically_allow_all",
      "resource_type": "aws_iam_policy",
      "rule_description": "IAM policies should not allow broad list actions on S3 buckets. Should a malicious actor gain access to a role with a policy that includes broad list actions such as ListAllMyBuckets, the malicious actor would be able to enumerate all buckets and potentially extract sensitive data.",
      "rule_id": "FG_R00218",
      "rule_message": "",
      "rule_name": "tf_aws_iam_s3_nolist",
      "rule_result": "PASS",
      "rule_severity": "Medium",
      "rule_summary": "IAM policies should not allow broad list actions on S3 buckets",
      "source_location": [
        {
          "path": "infra_tf/main.tf",
          "line": 6,
          "column": 1
        }
      ]
    },
    {
      "controls": [],
      "filepath": "infra_tf/main.tf",
      "input_type": "tf",
      "provider": "aws",
      "resource_id": "aws_iam_policy.basically_deny_all",
      "resource_type": "aws_iam_policy",
      "rule_description": "IAM policies should not allow broad list actions on S3 buckets. Should a malicious actor gain access to a role with a policy that includes broad list actions such as ListAllMyBuckets, the malicious actor would be able to enumerate all buckets and potentially extract sensitive data.",
      "rule_id": "FG_R00218",
      "rule_message": "",
      "rule_name": "tf_aws_iam_s3_nolist",
      "rule_result": "PASS",
      "rule_severity": "Medium",
      "rule_summary": "IAM policies should not allow broad list actions on S3 buckets",
      "source_location": [
        {
          "path": "infra_tf/main.tf",
          "line": 25,
          "column": 1
        }
      ]
    }
  ],
  "summary": {
    "filepaths": [
      "infra_tf/main.tf"
    ],
    "rule_results": {
      "FAIL": 2,
      "PASS": 4,
      "WAIVED": 0
    },
    "severities": {
      "Critical": 0,
      "High": 1,
      "Informational": 0,
      "Low": 1,
      "Medium": 0,
      "Unknown": 0
    }
  }
}
```

The summary at the end is the most important part -- it's a breakdown of the compliance state of your infrastructure-as-code. In this case, there were 2 `FAIL` rule results. This is great, because now we know there's a policy violation in our Terraform!

Above, you can see that the resource `aws_iam_policy.basically_allow_all` had a `FAIL` result for the rule [`tf_aws_iam_admin_policy`](https://github.com/fugue/regula/blob/master/rego/rules/tf/aws/iam/admin_policy.rego), which maps to the control `CIS-AWS_v1.2.0_1.22`.

The resource _also_ failed the custom rule [`long_description`](https://github.com/fugue/regula-ci-example/blob/master/example_custom_rule/long_description.rego), which has a `Low` severity.

Further down, you can see that the resource `aws_iam_policy.basically_deny_all` has a rule result of `PASS` for both rules.

#### Results - invalid CloudFormation

The output for our example **Regula CloudFormation** job is similar, as our invalid CloudFormation template had 7 `FAIL` rule results of varying severity and 10 `PASS` rule results. Here's the summary at the very end of the job log:

```
  "summary": {
    "filepaths": [
      "infra_cfn/cloudformation.yaml"
    ],
    "rule_results": {
      "FAIL": 7,
      "PASS": 10,
      "WAIVED": 0
    },
    "severities": {
      "Critical": 0,
      "High": 6,
      "Informational": 0,
      "Low": 1,
      "Medium": 0,
      "Unknown": 0
    }
  }
```

#### Results - valid CloudFormation

The output for our example **Regula Valid CloudFormation** job has 0 `FAIL` rule results and 3 `PASS` rule results. There are 0 severities listed because no rules failed. Here's the summary:

```
   "summary": {
    "filepaths": [
      "infra_valid_cfn/cloudformation.yaml"
    ],
    "rule_results": {
      "FAIL": 0,
      "PASS": 3,
      "WAIVED": 0
    },
    "severities": {
      "Critical": 0,
      "High": 0,
      "Informational": 0,
      "Low": 0,
      "Medium": 0,
      "Unknown": 0
    }
  }
```

#### Results - multiple CloudFormation templates

In our example **Regula multiple CloudFormation templates**, there are two `filepaths` listed because we passed in two CloudFormation templates:

```
  "summary": {
    "filepaths": [
      "infra_cfn/cloudformation.yaml",
      "infra_valid_cfn/cloudformation.yaml"
    ],
    "rule_results": {
      "FAIL": 7,
      "PASS": 13,
      "WAIVED": 0
    },
    "severities": {
      "Critical": 0,
      "High": 6,
      "Informational": 0,
      "Low": 1,
      "Medium": 0,
      "Unknown": 0
    }
  }
```

#### Results - CloudFormation and Terraform

In our example **Regula on CloudFormation and Terraform**, `filepaths` lists each CloudFormation template and Terraform project directory:

```
  "summary": {
    "filepaths": [
      "infra_cfn/cloudformation.yaml",
      "infra_tf/main.tf",
      "infra_valid_cfn/cloudformation.yaml"
    ],
    "rule_results": {
      "FAIL": 8,
      "PASS": 16,
      "WAIVED": 0
    },
    "severities": {
      "Critical": 0,
      "High": 7,
      "Informational": 0,
      "Low": 1,
      "Medium": 0,
      "Unknown": 0
    }
  }
```

## Further Reading
For more information about Regula and how to use it, check out these resources:

- [Regula repository](https://github.com/fugue/regula)
- [Regula documentation](https://regula.dev)
- [Regula GitHub Action](https://github.com/fugue/regula-action)
- [fregot](https://github.com/fugue/fregot)
- [OPA](https://www.openpolicyagent.org/)

[regula]: https://github.com/fugue/regula
