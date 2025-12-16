locals {
  # Extract availability zone names for the specified region
  # Limit to 3 if multi-az or 1 if single-az
  region_azs = var.multi_az ? slice(
    [for zone in data.aws_availability_zones.available.names : format("%s", zone)],
    0, 3
    ) : slice(
    [for zone in data.aws_availability_zones.available.names : format("%s", zone)],
    0, 1
  )

  # Calculate worker node replicas based on multi-az setting
  worker_node_replicas = var.multi_az ? 3 : 2

  # If cluster_name is not null, use that, otherwise generate a random cluster name
  cluster_name = coalesce(var.cluster_name, "rosa-${random_string.random_name.result}")
}
