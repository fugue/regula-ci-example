provider "aws" {
  region = "eu-west-1"
}

resource "aws_ebs_volume" "bad" {
  availability_zone = "us-west-2a"
  size              = 8
}

resource "aws_ebs_volume" "good" {
  availability_zone = "us-west-2a"
  size              = 8
  encrypted         = true
}

resource "aws_ebs_volume" "large" {
  availability_zone = "us-west-2a"
  size              = 32
  encrypted         = true
}
