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
  host     = module.rosa_hcp.cluster_api_url
  username = module.rosa_hcp.cluster_admin_username
  password = module.rosa_hcp.cluster_admin_password
}
