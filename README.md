# regula-ci-example

An example of using [regula] in CI.

It is currently set up with the following CI systems:

 -  GitHub Actions: [.github/workflows/main.yml](.github/workflows/main.yml).
 -  Travis: [.travis.yml](.travis.yml)

There is an example of a custom rule for this repository as well --
[example\_custom\_rule/long_description.rego](example\_custom\_rule/long_description.rego).
By passing this directory to regula, it gets included in the report.

[regula]: https://github.com/fugue/regula
