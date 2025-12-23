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

variable "machine_type" {
  type        = list(string)
}

# ⚠️ Variables declaradas pero NO utilizadas
variable "unused_variable" {
  description = "value"
  type        = string
  default     = "not-used"
}
