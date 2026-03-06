output "ca_pool_name" {
  description = "CA pool name — use in GoogleCASIssuer CRD: spec.caPoolId"
  value       = google_privateca_ca_pool.this.name
}

output "ca_pool_id" {
  description = "Full CA pool resource path — use in IAM member ca_pool attribute"
  value       = google_privateca_ca_pool.this.id
}

output "ca_pool_location" {
  description = "CA pool region — use in GoogleCASIssuer CRD: spec.location"
  value       = google_privateca_ca_pool.this.location
}

output "ca_id" {
  description = "Certificate authority ID"
  value       = google_privateca_certificate_authority.this.certificate_authority_id
}

output "ca_cert_pem" {
  description = "Root CA certificate PEM — paste into Linkerd identityTrustAnchorsPEM"
  value       = google_privateca_certificate_authority.this.pem_ca_certificates[0]
}
