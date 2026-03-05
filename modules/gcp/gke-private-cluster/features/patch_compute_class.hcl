# Feature: patch_compute_class
# Patches upstream cluster_autoscaling so that auto_provisioning_defaults is
# created when enable_default_compute_class = true (even when NAP enabled = false).
# Opt-in per cluster by adding to the cluster's terragrunt.hcl:
#
#   include "patch_compute_class" {
#     path = "${get_repo_root()}/modules/gcp/gke-private-cluster/features/patch_compute_class.hcl"
#   }
#
# Toggle via inputs: cluster_autoscaling = { enable_default_compute_class = true }
# Safe no-op when enable_default_compute_class is false/absent.

generate "patch_compute_class" {
  path      = "compute_class_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    resource "google_container_cluster" "primary" {
      cluster_autoscaling {
        enabled                       = var.cluster_autoscaling.enabled
        default_compute_class_enabled = lookup(var.cluster_autoscaling, "enable_default_compute_class", false)

        dynamic "auto_provisioning_defaults" {
          # FIX: also create this block when enable_default_compute_class = true
          for_each = var.cluster_autoscaling.enabled || lookup(var.cluster_autoscaling, "enable_default_compute_class", false) ? [1] : []

          content {
            service_account   = local.service_account
            oauth_scopes      = local.node_pools_oauth_scopes["all"]
            boot_disk_kms_key = var.boot_disk_kms_key

            management {
              auto_repair  = lookup(var.cluster_autoscaling, "auto_repair", true)
              auto_upgrade = lookup(var.cluster_autoscaling, "auto_upgrade", true)
            }

            disk_size = lookup(var.cluster_autoscaling, "disk_size", 100)
            disk_type = lookup(var.cluster_autoscaling, "disk_type", "pd-standard")

            upgrade_settings {
              strategy        = lookup(var.cluster_autoscaling, "strategy", "SURGE")
              max_surge       = lookup(var.cluster_autoscaling, "strategy", "SURGE") == "SURGE" ? lookup(var.cluster_autoscaling, "max_surge", 0) : null
              max_unavailable = lookup(var.cluster_autoscaling, "strategy", "SURGE") == "SURGE" ? lookup(var.cluster_autoscaling, "max_unavailable", 0) : null

              dynamic "blue_green_settings" {
                for_each = lookup(var.cluster_autoscaling, "strategy", "SURGE") == "BLUE_GREEN" ? [1] : []
                content {
                  node_pool_soak_duration = lookup(var.cluster_autoscaling, "node_pool_soak_duration", null)
                  standard_rollout_policy {
                    batch_soak_duration = lookup(var.cluster_autoscaling, "batch_soak_duration", null)
                    batch_percentage    = lookup(var.cluster_autoscaling, "batch_percentage", null)
                    batch_node_count    = lookup(var.cluster_autoscaling, "batch_node_count", null)
                  }
                }
              }
            }

            shielded_instance_config {
              enable_secure_boot          = lookup(var.cluster_autoscaling, "enable_secure_boot", false)
              enable_integrity_monitoring = lookup(var.cluster_autoscaling, "enable_integrity_monitoring", true)
            }

            image_type = lookup(var.cluster_autoscaling, "image_type", "COS_CONTAINERD")
          }
        }

        autoscaling_profile = var.cluster_autoscaling.autoscaling_profile != null ? var.cluster_autoscaling.autoscaling_profile : "BALANCED"

        dynamic "resource_limits" {
          for_each = local.autoscaling_resource_limits
          content {
            resource_type = resource_limits.value["resource_type"]
            minimum       = resource_limits.value["minimum"]
            maximum       = resource_limits.value["maximum"]
          }
        }
      }
    }
  EOF
}
