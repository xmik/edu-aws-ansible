variable "region" {
  default = "eu-west-1"
}
provider "aws" {
  # this may be set in ~/.aws/config file, but it still needs to be set here
  # https://github.com/terraform-providers/terraform-provider-aws/issues/687
  region = "${var.region}"
}
