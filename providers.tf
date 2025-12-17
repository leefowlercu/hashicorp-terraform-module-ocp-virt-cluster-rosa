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
#
# Two-phase deployment:
# Phase 1: create_kubernetes_resources = false (default), cluster created
# Phase 2: Set cluster_api_url_override, cluster_domain_override, create_kubernetes_resources = true

locals {
  # Use override variables if set, otherwise use placeholder to prevent provider init errors
  k8s_host           = var.cluster_api_url_override != "" ? var.cluster_api_url_override : "https://placeholder.local"
  k8s_cluster_domain = var.cluster_domain_override != "" ? var.cluster_domain_override : "placeholder.local"
}

provider "kubernetes" {
  host     = local.k8s_host
  insecure = true

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "/bin/bash"
    args = [
      "-c",
      <<-EOF
        set -e
        # Skip auth if using placeholder (Phase 1)
        if [ "${local.k8s_cluster_domain}" = "placeholder.local" ]; then
          printf '{"apiVersion":"client.authentication.k8s.io/v1beta1","kind":"ExecCredential","status":{"token":"placeholder"}}'
          exit 0
        fi

        # OAuth endpoint is at apps subdomain, not API URL
        OAUTH_URL="https://oauth-openshift.apps.${local.k8s_cluster_domain}/oauth/authorize?client_id=openshift-challenging-client&response_type=token"

        # Request token using challenging client flow
        RESPONSE=$(curl -skI -u "${var.admin_username}:${var.admin_password}" \
          -H "X-CSRF-Token: 1" \
          "$OAUTH_URL" 2>&1)

        # Extract token from Location header redirect
        LOCATION=$(echo "$RESPONSE" | grep -i "^location:" | tr -d '\r')
        TOKEN=$(echo "$LOCATION" | sed -E 's/.*access_token=([^&]*).*/\1/')

        # Return ExecCredential JSON
        if [ -n "$TOKEN" ] && [ "$TOKEN" != "$LOCATION" ]; then
          printf '{"apiVersion":"client.authentication.k8s.io/v1beta1","kind":"ExecCredential","status":{"token":"%s"}}' "$TOKEN"
        else
          echo "Failed to obtain token. Response: $RESPONSE" >&2
          exit 1
        fi
      EOF
    ]
  }
}
