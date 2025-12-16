module "rosa_hcp" {
  source  = "terraform-redhat/rosa-hcp/rhcs"
  version = "1.7.1"

  cluster_name               = local.cluster_name
  openshift_version          = var.openshift_version
  account_role_prefix        = local.cluster_name
  operator_role_prefix       = local.cluster_name
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
