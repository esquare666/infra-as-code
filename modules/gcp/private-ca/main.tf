resource "google_project_service" "privateca" {
  project            = var.project_id
  service            = "privateca.googleapis.com"
  disable_on_destroy = false
}

# CA Pool — groups CAs together; IAM is granted at pool level
resource "google_privateca_ca_pool" "this" {
  project  = var.project_id
  name     = var.pool_name
  location = var.location
  tier     = var.tier

  publishing_options {
    publish_ca_cert = true
    publish_crl     = false # not needed for short-lived Linkerd certs
  }

  issuance_policy {
    maximum_lifetime = var.maximum_cert_lifetime

    baseline_values {
      ca_options {
        is_ca = false
      }
      key_usage {
        base_key_usage {
          digital_signature = true
          key_encipherment  = true
        }
        extended_key_usage {
          server_auth = true
          client_auth = true
        }
      }
    }
  }

  depends_on = [google_project_service.privateca]
}

# Root CA — HSM-backed key, managed entirely by GCP
resource "google_privateca_certificate_authority" "this" {
  project                  = var.project_id
  location                 = var.location
  pool                     = google_privateca_ca_pool.this.name
  certificate_authority_id = var.ca_id
  deletion_protection      = var.deletion_protection

  config {
    subject_config {
      subject {
        organization = var.organization
        common_name  = var.common_name
      }
    }
    x509_config {
      ca_options {
        is_ca                  = true
        max_issuer_path_length = 1
      }
      key_usage {
        base_key_usage {
          cert_sign = true
          crl_sign  = true
        }
        extended_key_usage {}
      }
    }
  }

  key_spec {
    algorithm = "EC_P256_SHA256"
  }

  lifetime = var.ca_lifetime

  depends_on = [google_privateca_ca_pool.this]
}
