output "id" {
  description = "ID of the Valkey instance"
  value       = google_memorystore_instance.valkey.id
}

output "name" {
  description = "Name of the Valkey instance"
  value       = google_memorystore_instance.valkey.name
}

output "endpoints" {
  description = "Endpoints of the Valkey instance"
  value       = google_memorystore_instance.valkey.endpoints
}

output "service_connection_policies" {
  description = "Service connection policies created for PSC"
  value       = google_network_connectivity_service_connection_policy.scp
}
