terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

#Firewall abierto al mundo entero
resource "google_compute_firewall" "allow_all" {
  name    = "allow-all-traffic"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Cloud SQL con IP pública accesible desde internet
resource "google_sql_database_instance" "main" {
  name             = "demo-db"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        value = "0.0.0.0/0"
      }
    }
  }
}

# Storage bucket sin versionado habilitado
resource "google_storage_bucket" "app_data" {
  name     = "demo-app-data-bucket"
  location = var.region

   # Falta logging { ... } para auditar accesos
}

