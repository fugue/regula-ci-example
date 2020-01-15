# regula-ci-example

An example of using [regula] in CI.

The configuration is here:
[.github/workflows/main.yml](.github/workflows/main.yml).

There is an example of a custom rule for this repository as well --
[example\_custom\_rule/long_description.rego](example\_custom\_rule/long_description.rego).
By passing this directory to regula, it gets included in the report.

[regula]: https://github.com/fugue/regula
