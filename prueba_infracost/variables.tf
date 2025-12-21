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

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
}

variable "sql_instances" {
  description = "Map of Cloud SQL instances to create"
  type = map(object({
    database_version = string
    tier            = string
  }))
}
