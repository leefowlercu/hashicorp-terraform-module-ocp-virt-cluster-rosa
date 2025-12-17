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
  host     = module.rosa_hcp.cluster_api_url
  insecure = true

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "/bin/bash"
    args = [
      "-c",
      <<-EOF
        set -e
        # OAuth endpoint is at apps subdomain, not API URL
        OAUTH_URL="https://oauth-openshift.apps.${module.rosa_hcp.cluster_domain}/oauth/authorize?client_id=openshift-challenging-client&response_type=token"

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
