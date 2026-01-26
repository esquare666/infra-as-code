locals {
  network_project = coalesce(var.network_project, var.project_id)
}

resource "google_project_service" "apis" {
  for_each = toset([
    "memorystore.googleapis.com",
    "serviceconsumermanagement.googleapis.com",
    "networkconnectivity.googleapis.com",
    "compute.googleapis.com",
  ])

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_network_connectivity_service_connection_policy" "scp" {
  for_each = var.service_connection_policies

  project       = coalesce(each.value.network_project, var.project_id)
  name          = each.key
  location      = var.location
  service_class = "gcp-memorystore"
  description   = each.value.description
  labels        = each.value.labels
  network       = "projects/${coalesce(each.value.network_project, var.project_id)}/global/networks/${each.value.network_name}"

  psc_config {
    subnetworks = [for subnet in each.value.subnet_names : "projects/${coalesce(each.value.network_project, var.project_id)}/regions/${var.location}/subnetworks/${subnet}"]
    limit       = each.value.limit
  }

  depends_on = [google_project_service.apis]
}

resource "google_memorystore_instance" "valkey" {
  project             = var.project_id
  instance_id         = var.instance_id
  location            = var.location
  shard_count         = var.shard_count
  replica_count       = var.replica_count
  node_type           = var.node_type
  engine_version      = var.engine_version
  authorization_mode  = var.authorization_mode
  transit_encryption_mode     = var.transit_encryption_mode
  deletion_protection_enabled = var.deletion_protection_enabled
  labels              = var.labels
  engine_configs      = var.engine_configs

  desired_auto_created_endpoints {
    network    = "projects/${local.network_project}/global/networks/${var.network}"
    project_id = var.project_id
  }

  depends_on = [
    google_project_service.apis,
    google_network_connectivity_service_connection_policy.scp,
  ]
}
