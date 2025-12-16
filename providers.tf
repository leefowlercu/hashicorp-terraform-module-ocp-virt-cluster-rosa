provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.default_aws_tags
  }

  ignore_tags {
    key_prefixes = [
      "kubernetes.io/",
    ]
  }
}

provider "rhcs" {
  token = var.rhcs_token
}
