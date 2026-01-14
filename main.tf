module "rosa_hcp" {
  source  = "terraform-redhat/rosa-hcp/rhcs"
  version = "1.7.1"

  cluster_name               = var.cluster_name
  openshift_version          = var.openshift_version
  account_role_prefix        = var.cluster_name
  operator_role_prefix       = var.cluster_name
  replicas                   = local.worker_node_replicas
  aws_availability_zones     = local.region_azs
  create_oidc                = true
  private                    = var.private_cluster
  aws_subnet_ids             = var.aws_subnet_ids
  create_account_roles       = true
  create_operator_roles      = true
  compute_machine_type       = var.compute_machine_type
  admin_credentials_username = var.admin_username
  admin_credentials_password = var.admin_password
}

### Terraform Automation Service Account
# Creates a service account with cluster-admin privileges and a long-lived token
# for downstream Terraform workspaces that need to use kubernetes_manifest resources
#
# Only created when create_kubernetes_resources = true (Phase 2)

# resource "kubernetes_service_account_v1" "terraform" {
#   count = var.create_kubernetes_resources ? 1 : 0

#   metadata {
#     name      = "terraform-automation"
#     namespace = "kube-system"
#   }
# }

# resource "kubernetes_cluster_role_binding_v1" "terraform_admin" {
#   count = var.create_kubernetes_resources ? 1 : 0

#   metadata {
#     name = "terraform-automation-admin"
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-admin"
#   }
#   subject {
#     kind      = "ServiceAccount"
#     name      = kubernetes_service_account_v1.terraform[0].metadata[0].name
#     namespace = kubernetes_service_account_v1.terraform[0].metadata[0].namespace
#   }
# }

# resource "kubernetes_secret_v1" "terraform_token" {
#   count = var.create_kubernetes_resources ? 1 : 0

#   metadata {
#     name      = "terraform-automation-token"
#     namespace = "kube-system"
#     annotations = {
#       "kubernetes.io/service-account.name" = kubernetes_service_account_v1.terraform[0].metadata[0].name
#     }
#   }
#   type = "kubernetes.io/service-account-token"
# }
