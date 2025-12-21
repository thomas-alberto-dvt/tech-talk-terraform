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

# Compute Engine Instance
resource "google_compute_instance" "demo_vm" {
  for_each     = toset(var.machine_type)
  name         = "vm-${each.key}"
  machine_type = each.key
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = var.disk_size_gb
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
  }
}

resource "google_sql_database_instance" "demo_db" {
  for_each         = var.sql_instances
  name             = each.key
  database_version = each.value.database_version
  region           = var.region
  
  settings {
    tier = each.value.tier
  }

  labels = {
    environment = "dev"
    service     = "demo-database"
  }
}

resource "google_compute_address" "static_ip" {
  name = "demo-static-ip"
  region = var.region
}
