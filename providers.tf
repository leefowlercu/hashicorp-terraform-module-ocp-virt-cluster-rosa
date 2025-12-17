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
# Uses exec-based authentication to obtain OAuth token from OpenShift at runtime
# The challenging client OAuth flow requires the X-CSRF-Token header
provider "kubernetes" {
  host                   = module.rosa_hcp.cluster_api_url
  client_certificate     = null
  client_key             = null
  cluster_ca_certificate = null

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "/bin/bash"
    args = [
      "-c",
      <<-EOF
        set -e
        OAUTH_URL="${module.rosa_hcp.cluster_api_url}/oauth/authorize?client_id=openshift-challenging-client&response_type=token"
        LOCATION=$(curl -skI -u "${var.admin_username}:${var.admin_password}" -H "X-CSRF-Token: 1" "$OAUTH_URL" 2>/dev/null | grep -i "^location:" | tr -d '\r')
        TOKEN=$(echo "$LOCATION" | sed -E 's/.*access_token=([^&]*).*/\1/')
        printf '{"apiVersion":"client.authentication.k8s.io/v1beta1","kind":"ExecCredential","status":{"token":"%s"}}' "$TOKEN"
      EOF
    ]
  }
}
