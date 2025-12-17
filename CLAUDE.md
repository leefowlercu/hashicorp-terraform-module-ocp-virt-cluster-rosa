# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Terraform root module that deploys ROSA HCP (Red Hat OpenShift Service on AWS - Hosted Control Plane) clusters with integrated Kubernetes provider authentication for downstream automation.

## Commands

```bash
terraform init                    # Initialize providers and modules
terraform validate                # Validate configuration syntax
terraform fmt -check              # Check formatting
terraform fmt                     # Auto-format files
terraform plan                    # Preview changes
terraform apply                   # Apply changes
```

## Architecture

### Two-Phase Deployment Pattern

This module uses a two-phase deployment to solve the Kubernetes provider chicken-and-egg problem (provider needs cluster info that doesn't exist until after apply):

**Phase 1** - Default state (`create_kubernetes_resources = false`):
- Creates ROSA HCP cluster via `terraform-redhat/rosa-hcp/rhcs` module
- Kubernetes provider uses placeholder values, returns dummy token
- No kubernetes resources created (`count = 0`)

**Phase 2** - After cluster exists:
- Set `cluster_api_url_override` and `cluster_domain_override` from Phase 1 outputs
- Set `create_kubernetes_resources = true`
- Creates service account with cluster-admin and long-lived token

### Kubernetes Provider OAuth Authentication

The kubernetes provider uses exec-based authentication (`providers.tf`) that:
1. Passes credentials via `env` block to avoid shell escaping issues
2. Constructs base64 auth header manually (special characters like `!@#` break `curl -u`)
3. Calls ROSA HCP OAuth endpoint at `oauth.<cluster_domain>:443` (not `oauth-openshift.apps...`)
4. Extracts access token from Location header redirect
5. Returns ExecCredential JSON

Key implementation details:
- Use `%%{` to escape `%` in heredocs (Terraform interprets `%{` as template directive)
- OAuth URL for ROSA HCP differs from standard OpenShift (`oauth.<domain>` vs `oauth-openshift.apps.<domain>`)
- Placeholder domain check short-circuits auth in Phase 1

### File Structure

- `main.tf` - ROSA module invocation and kubernetes resources (SA, RBAC, token secret)
- `providers.tf` - AWS, RHCS, and Kubernetes provider configs with OAuth exec script
- `variables.tf` - Input variables including Phase 2 override variables
- `outputs.tf` - Cluster endpoints and `cluster_token` for downstream use
- `environments/*.tfvars` - Environment-specific variable values

## Authentication Requirements

- AWS credentials via standard methods
- `RHCS_TOKEN` environment variable for ROSA/OCM API
- Admin username/password for OpenShift OAuth (Phase 2)
