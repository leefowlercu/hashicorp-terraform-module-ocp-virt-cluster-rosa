### ROSA Cluster Outputs

output "cluster_id" {
  description = "Unique identifier of the ROSA cluster."
  value       = module.rosa_hcp.cluster_id
}

output "cluster_api_url" {
  description = "URL of the cluster API server."
  value       = module.rosa_hcp.cluster_api_url
}

output "cluster_console_url" {
  description = "URL of the OpenShift web console."
  value       = module.rosa_hcp.cluster_console_url
}

output "cluster_domain" {
  description = "DNS domain of the cluster."
  value       = module.rosa_hcp.cluster_domain
}

output "cluster_admin_username" {
  description = "Username for the cluster admin user."
  value       = module.rosa_hcp.cluster_admin_username
  sensitive   = true
}

output "cluster_admin_password" {
  description = "Password for the cluster admin user."
  value       = module.rosa_hcp.cluster_admin_password
  sensitive   = true
}
