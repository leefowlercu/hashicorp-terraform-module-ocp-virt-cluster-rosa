aws_region           = "us-east-1"
cluster_name         = "ocp-virt-cluster-dev"
openshift_version    = "4.20.5"
multi_az             = true
worker_node_replicas = 3
private_cluster      = false
compute_machine_type = "m7g.metal"
admin_username       = "cluster-admin"

default_aws_tags = {
  Environment = "development"
  Project     = "ocp-virt-cluster"
  ManagedBy   = "terraform"
}

additional_tags = {}

# aws_subnet_ids must be provided based on your VPC configuration
# aws_subnet_ids = ["subnet-xxx", "subnet-yyy", "subnet-zzz"]
