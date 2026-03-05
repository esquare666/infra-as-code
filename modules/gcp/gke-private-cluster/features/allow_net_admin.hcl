# Feature: allow_net_admin
# The private-cluster module does not expose allow_net_admin, so this patches
# it via a Terraform override file (auto deep-merged with upstream cluster.tf).
# Opt-in per cluster by adding to the cluster's terragrunt.hcl:
#
#   include "allow_net_admin" {
#     path = "${get_repo_root()}/modules/gcp/gke-private-cluster/features/allow_net_admin.hcl"
#   }

generate "allow_net_admin" {
  path      = "allow_net_admin_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    resource "google_container_cluster" "primary" {
      allow_net_admin = true
    }
  EOF
}
