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
  description = "Compute Engine machine type"
  type        = list(string)
}

# ⚠️ Variables declaradas pero NO utilizadas
variable "unused_variable" {
  description = "Esta variable nunca se usa en el código"
  type        = string
  default     = "not-used"
}
