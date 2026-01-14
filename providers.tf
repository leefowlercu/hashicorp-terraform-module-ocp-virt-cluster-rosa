### AWS Provider Configuration - Authorization via HCP Dynamic AWS Credentials
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
  # Use override variables only when Phase 2 is enabled, otherwise use placeholder to prevent provider init errors
  k8s_host           = var.create_kubernetes_resources && var.cluster_api_url_override != "" ? var.cluster_api_url_override : "https://placeholder.local"
  k8s_cluster_domain = var.create_kubernetes_resources && var.cluster_domain_override != "" ? var.cluster_domain_override : "placeholder.local"
}

provider "kubernetes" {
  host     = local.k8s_host
  insecure = true

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "/bin/bash"
    env = {
      OAUTH_USERNAME = var.admin_username
      OAUTH_PASSWORD = var.admin_password
      CLUSTER_DOMAIN = local.k8s_cluster_domain
    }
    args = [
      "-c",
      <<-EOF
        set -e
        # Skip auth if using placeholder (Phase 1)
        if [ "$CLUSTER_DOMAIN" = "placeholder.local" ]; then
          printf '{"apiVersion":"client.authentication.k8s.io/v1beta1","kind":"ExecCredential","status":{"token":"placeholder"}}'
          exit 0
        fi

        # OAuth endpoint for ROSA HCP is at oauth.<cluster_domain>:443
        OAUTH_URL="https://oauth.$CLUSTER_DOMAIN:443/oauth/authorize?client_id=openshift-challenging-client&response_type=token"

        # Request token using challenging client flow
        # Build auth header manually to avoid shell escaping issues with special characters
        AUTH_HEADER=$(printf '%s:%s' "$OAUTH_USERNAME" "$OAUTH_PASSWORD" | base64 | tr -d '\n')
        HEADERS=$(curl -skI -H "Authorization: Basic $AUTH_HEADER" -H "X-CSRF-Token: 1" "$OAUTH_URL" 2>&1)

        # Extract token from Location header redirect
        LOCATION=$(echo "$HEADERS" | grep -i "^location:" | head -1 | tr -d '\r' || true)
        TOKEN=$(echo "$LOCATION" | sed -E 's/.*access_token=([^&]*).*/\1/')

        # Return ExecCredential JSON
        if [ -n "$TOKEN" ] && [ "$TOKEN" != "$LOCATION" ] && [ "$TOKEN" != "" ]; then
          printf '{"apiVersion":"client.authentication.k8s.io/v1beta1","kind":"ExecCredential","status":{"token":"%s"}}' "$TOKEN"
        else
          echo "failed to obtain oauth token from $OAUTH_URL" >&2
          exit 1
        fi
      EOF
    ]
  }
}
