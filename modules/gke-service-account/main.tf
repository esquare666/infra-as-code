resource "google_service_account" "gke" {
  project      = var.project_id
  account_id   = var.name
  display_name = var.display_name != null ? var.display_name : "GKE Node Service Account - ${var.name}"
}

resource "google_project_iam_member" "gke_roles" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke.email}"
}
