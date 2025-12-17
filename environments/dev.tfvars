aws_region           = "us-east-1"
aws_subnet_ids       = ["subnet-01cae5f1265bb03ff", "subnet-0a2caed32910797f2", "subnet-096c0e22b3551518d", "subnet-0214a61679d7f0fea", "subnet-04cc9e67caf1c51f5", "subnet-0a4971856eaf0e839"]
cluster_name         = "ocp-virt-cluster-dev"
openshift_version    = "4.20.5"
multi_az             = true
worker_node_replicas = 3
private_cluster      = false
compute_machine_type = "m7g.metal"
admin_username       = "lee.fowler"

default_aws_tags = {
  Environment = "development"
  Project     = "ocp-virt-cluster"
  ManagedBy   = "terraform"
}

additional_tags = {}
