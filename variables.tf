### AWS Variables

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources in."
}

variable "default_aws_tags" {
  type        = map(string)
  default     = {}
  description = "A map of default tags to apply to AWS resources."
}

variable "additional_tags" {
  type        = map(string)
  default     = {}
  description = "Additional AWS resource tags."
}

variable "aws_subnet_ids" {
  type        = list(string)
  description = "A list of either the public or public + private subnet IDs to use for the cluster."
}

### ROSA Variables

variable "openshift_version" {
  type        = string
  description = "Desired version of OpenShift for the cluster, for example '4.14.20'. If version is greater than the currently running version, an upgrade will be scheduled."
}

variable "cluster_name" {
  type        = string
  default     = null
  description = "The name of the ROSA cluster to create. If not provided, a random name will be generated."
}

variable "multi_az" {
  type        = bool
  default     = true
  description = "Multi AZ cluster for high availability."
}

variable "worker_node_replicas" {
  type        = number
  default     = 3
  description = "Number of worker nodes to provision. Single zone clusters need at least 2 nodes, multizone clusters need at least 3 nodes."
}

variable "private_cluster" {
  type        = bool
  description = "If you want to create a private cluster, set this value to 'true'. If you want a publicly available cluster, set this value to 'false'."
}

variable "compute_machine_type" {
  type        = string
  description = "The AWS instance type to use for the compute nodes."
}

variable "admin_username" {
  type        = string
  description = "The username for the cluster admin user."
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "The password for the cluster admin user."
}

### Kubernetes Provider Variables (for two-phase deployment)

variable "create_kubernetes_resources" {
  type        = bool
  default     = false
  description = "Set to true after cluster is created to enable kubernetes resource creation. Requires cluster_api_url and cluster_domain to be set."
}

variable "cluster_api_url_override" {
  type        = string
  default     = ""
  description = "Override for cluster API URL. Set this from cluster_api_url output after Phase 1."
}

variable "cluster_domain_override" {
  type        = string
  default     = ""
  description = "Override for cluster domain. Set this from cluster_domain output after Phase 1."
}
