variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "name" {
  description = "Service account ID (account_id)"
  type        = string
}

variable "display_name" {
  description = "Display name for the service account"
  type        = string
  default     = null
}

variable "roles" {
  description = "List of IAM roles to grant to the service account"
  type        = list(string)
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/artifactregistry.reader",
  ]
}
