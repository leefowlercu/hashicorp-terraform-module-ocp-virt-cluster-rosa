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

### ROSA Provider - Authorization via RHCS_TOKEN Environment Variable
provider "rhcs" {}

### Kubernetes Provider - For creating service account token
provider "kubernetes" {
  host     = "https://api.i5l5s2f8k3e6t2a.b08k.p3.openshiftapps.com:443"
  username = var.admin_username
  password = var.admin_password
  insecure = true
}
