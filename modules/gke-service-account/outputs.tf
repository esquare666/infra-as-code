output "email" {
  description = "Service account email"
  value       = google_service_account.gke.email
}

output "id" {
  description = "Service account ID"
  value       = google_service_account.gke.id
}

output "name" {
  description = "Service account name"
  value       = google_service_account.gke.name
}
