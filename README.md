# Terraform ROSA HCP Cluster Module

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.9-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Provider%206.x-FF9900?logo=amazonaws)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![RHCS](https://img.shields.io/badge/RHCS-Provider%201.7-EE0000?logo=redhat)](https://registry.terraform.io/providers/terraform-redhat/rhcs/latest)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Terraform module for deploying Red Hat OpenShift Service on AWS (ROSA) Hosted Control Plane (HCP) clusters with integrated Kubernetes provider authentication for downstream automation.

**Current Version**: N/A

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Two-Phase Deployment](#two-phase-deployment)
- [Requirements](#requirements)
- [Variables](#variables)
- [Outputs](#outputs)
- [Authentication](#authentication)

## Overview

This module provisions a fully managed ROSA HCP cluster on AWS and configures Kubernetes provider authentication using OpenShift's OAuth challenging client flow. Key features include:

- Deploys ROSA HCP clusters using the official `terraform-redhat/rosa-hcp/rhcs` module
- Configures exec-based Kubernetes provider authentication with dynamic OAuth token generation
- Creates a Terraform automation service account with cluster-admin privileges
- Generates long-lived service account tokens for downstream Terraform workspaces
- Supports single-AZ and multi-AZ deployments

## Quick Start

1. Configure authentication:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export RHCS_TOKEN="your-rosa-token"
```

2. Create a `terraform.tfvars` file:

```hcl
aws_region           = "us-east-1"
aws_subnet_ids       = ["subnet-xxx", "subnet-yyy", "subnet-zzz"]
cluster_name         = "my-rosa-cluster"
openshift_version    = "4.20.5"
private_cluster      = false
compute_machine_type = "m6i.xlarge"
admin_username       = "cluster-admin"
admin_password       = "YourSecurePassword123!"
```

3. Deploy Phase 1 (cluster creation):

```bash
terraform init
terraform apply
```

4. Deploy Phase 2 (Kubernetes resources):

```bash
# Add to terraform.tfvars after cluster is created
create_kubernetes_resources = true
cluster_api_url_override    = "<cluster_api_url from outputs>"
cluster_domain_override     = "<cluster_domain from outputs>"

terraform apply
```

## Two-Phase Deployment

This module uses a two-phase deployment pattern to handle the Kubernetes provider authentication chicken-and-egg problem:

**Phase 1** - Cluster Creation:
- `create_kubernetes_resources = false` (default)
- Creates the ROSA HCP cluster and all AWS IAM resources
- Outputs cluster endpoints needed for Phase 2

**Phase 2** - Kubernetes Resources:
- Set `cluster_api_url_override` and `cluster_domain_override` from Phase 1 outputs
- Set `create_kubernetes_resources = true`
- Creates service account, RBAC bindings, and token secret
- Outputs `cluster_token` for downstream workspaces

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9 |
| aws | ~> 6.26 |
| rhcs | ~> 1.7 |
| kubernetes | ~> 3.0 |
| time | ~> 0.13 |
| null | ~> 3.2 |

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `aws_region` | AWS region for deployment | `string` | Yes |
| `aws_subnet_ids` | List of subnet IDs for the cluster | `list(string)` | Yes |
| `openshift_version` | OpenShift version (e.g., "4.20.5") | `string` | Yes |
| `private_cluster` | Deploy as private cluster | `bool` | Yes |
| `compute_machine_type` | AWS instance type for compute nodes | `string` | Yes |
| `admin_username` | Cluster admin username | `string` | Yes |
| `admin_password` | Cluster admin password | `string` | Yes |
| `cluster_name` | ROSA cluster name | `string` | No |
| `multi_az` | Enable multi-AZ deployment | `bool` | No |
| `worker_node_replicas` | Number of worker nodes | `number` | No |
| `create_kubernetes_resources` | Enable Phase 2 resources | `bool` | No |
| `cluster_api_url_override` | Cluster API URL for Phase 2 | `string` | No |
| `cluster_domain_override` | Cluster domain for Phase 2 | `string` | No |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| `cluster_id` | ROSA cluster identifier | No |
| `cluster_api_url` | Cluster API server URL | No |
| `cluster_console_url` | OpenShift web console URL | No |
| `cluster_domain` | DNS domain of the cluster | No |
| `cluster_admin_username` | Admin username | Yes |
| `cluster_admin_password` | Admin password | Yes |
| `cluster_token` | Service account token (Phase 2 only) | Yes |

## Authentication

### AWS

Configure AWS credentials using any standard method (environment variables, shared credentials file, IAM role).

### RHCS/ROSA

Set the `RHCS_TOKEN` environment variable with your Red Hat OpenShift Cluster Manager token.

### Kubernetes Provider

The module uses exec-based authentication with OpenShift's OAuth challenging client flow. This approach:

- Obtains OAuth tokens dynamically at runtime
- Handles special characters in passwords safely
- Uses the ROSA HCP OAuth endpoint (`oauth.<cluster_domain>:443`)
- Returns ExecCredential JSON for the Kubernetes provider
