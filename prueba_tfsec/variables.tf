variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "api_key" {
  description = "API Key (should not be in variables!)"
  type        = string
  sensitive   = true
}
