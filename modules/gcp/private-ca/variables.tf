variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "location" {
  description = "GCP region for the CA pool and CA (e.g. australia-southeast2)"
  type        = string
}

variable "pool_name" {
  description = "Name of the CA pool"
  type        = string
}

variable "ca_id" {
  description = "ID of the certificate authority within the pool"
  type        = string
}

variable "common_name" {
  description = "Common name for the root CA subject (e.g. root.linkerd.cluster.local)"
  type        = string
}

variable "organization" {
  description = "Organization name for the root CA subject"
  type        = string
  default     = ""
}

variable "tier" {
  description = "CA pool tier: DEVOPS (short-lived certs, cheaper) or ENTERPRISE"
  type        = string
  default     = "DEVOPS"

  validation {
    condition     = contains(["DEVOPS", "ENTERPRISE"], var.tier)
    error_message = "tier must be DEVOPS or ENTERPRISE"
  }
}

variable "ca_lifetime" {
  description = "Lifetime of the root CA certificate (default 10 years)"
  type        = string
  default     = "315360000s"
}

variable "maximum_cert_lifetime" {
  description = "Maximum lifetime for certificates issued from this pool"
  type        = string
  default     = "86400s" # 24h — matches Linkerd workload cert lifetime
}

variable "deletion_protection" {
  description = "Prevent accidental CA deletion. Set to false only to destroy."
  type        = bool
  default     = true
}
