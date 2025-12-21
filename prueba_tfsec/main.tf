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

# ⚠️ Compute Instance con múltiples problemas de seguridad
#tfsec:ignore:google-compute-enable-shielded-vm-im
#tfsec:ignore:google-compute-enable-shielded-vm-vtpm
#tfsec:ignore:google-compute-no-project-wide-ssh-keys
resource "google_compute_instance" "web_server" {
  name         = "web-server"
  machine_type = "e2-medium"
  zone         = var.zone

  #tfsec:ignore:google-compute-vm-disk-encryption-customer-key
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      # ⚠️ LOW: Sin customer-managed encryption key
    }
  }

  network_interface {
    network = "default"
    #tfsec:ignore:google-compute-no-public-ip
    access_config {
      # ⚠️ HIGH: IP pública asignada (expone instancia a internet)
    }
  }

  # ⚠️ MEDIUM: Permite uso de SSH keys a nivel de proyecto
  # ⚠️ MEDIUM: VTPM para Shielded VMs no habilitado
  # ⚠️ MEDIUM: Shielded VM integrity monitoring no habilitado
}

# ⚠️ CRITICAL: Firewall completamente abierto al mundo
resource "google_compute_firewall" "allow_all_ingress" {
  name    = "allow-all-ingress"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"] # ⚠️ CRITICAL: Todos los puertos TCP
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"] # ⚠️ CRITICAL: Todos los puertos UDP
  }

  #tfsec:ignore:google-compute-no-public-ingress
  source_ranges = ["0.0.0.0/0"] # ⚠️ CRITICAL: Desde cualquier IP (2 instancias)
}

# ⚠️ CRITICAL: Firewall SSH abierto a todo el mundo
resource "google_compute_firewall" "allow_ssh_public" {
  name    = "allow-ssh-public"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  #tfsec:ignore:google-compute-no-public-ingress
  source_ranges = ["0.0.0.0/0"] # ⚠️ CRITICAL: SSH desde cualquier IP
}

#tfsec:ignore:google-sql-enable-backup
# ⚠️ Cloud SQL con múltiples problemas de seguridad
#tfsec:ignore:google-sql-enable-backup
resource "google_sql_database_instance" "main" {
  name             = "main-instance"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    # ⚠️ MEDIUM: Sin backup automático habilitado
    # ⚠️ HIGH: TLS no requerido para conexiones

    #tfsec:ignore:google-sql-encrypt-in-transit-data
    ip_configuration {
      #tfsec:ignore:google-sql-no-public-access
      ipv4_enabled = true # ⚠️ HIGH: IP pública habilitada
      authorized_networks {
        #tfsec:ignore:google-sql-no-public-access
        value = "0.0.0.0/0" # ⚠️ HIGH: Acceso desde cualquier IP
      }
    }
  }

  #tfsec:ignore:google-storage-enable-ubla
  # ⚠️ deletion_protection no habilitado
}

#tfsec:ignore:google-storage-bucket-encryption-customer-key
# ⚠️ Storage bucket sin configuración de seguridad
#tfsec:ignore:google-storage-enable-ubla
#tfsec:ignore:google-storage-bucket-encryption-customer-key
resource "google_storage_bucket" "data" {
  name          = "${var.project_id}-data-bucket"
  location      = var.region
  force_destroy = true # ⚠️ Permite borrado forzado con datos

  # ⚠️ MEDIUM: Sin uniform_bucket_level_access
  # ⚠️ Sin versioning
  # ⚠️ LOW: Sin customer-managed encryption key
  #tfsec:ignore:google-storage-enable-ubla
  # ⚠️ Sin lifecycle rules
}
#tfsec:ignore:google-storage-bucket-encryption-customer-key

# ⚠️ Storage bucket público
#tfsec:ignore:google-storage-enable-ubla
#tfsec:ignore:google-storage-bucket-encryption-customer-key
resource "google_storage_bucket" "public_bucket" {
  name     = "${var.project_id}-public-bucket"
  location = var.region

  # ⚠️ MEDIUM: Sin uniform_bucket_level_access
  # ⚠️ LOW: Sin customer-managed encryption key
}

resource "google_storage_bucket_iam_member" "public_access" {
  bucket = google_storage_bucket.public_bucket.name
  role   = "roles/storage.objectViewer"
  #tfsec:ignore:google-storage-no-public-access
  member = "allUsers" # ⚠️ HIGH: Acceso público total al bucket
}

# ⚠️ Disco persistente sin encriptación adecuada
#tfsec:ignore:google-compute-disk-encryption-customer-key
resource "google_compute_disk" "data_disk" {
  name = "data-disk"
  type = "pd-ssd"
  zone = var.zone
  size = 100

  # ⚠️ LOW: Sin customer-managed encryption key
  # ⚠️ Sin snapshot_id para backup
}

# ⚠️ Secret Manager sin rotación
resource "google_secret_manager_secret" "api_key" {
  secret_id = "api-key"

  replication {
    auto {}
  }

  # ⚠️ Sin rotation policy
  # ⚠️ Sin expiration
}

resource "google_secret_manager_secret_version" "api_key_version" {
  secret      = google_secret_manager_secret.api_key.id
  secret_data = var.api_key # ⚠️ Secreto en variable, debería usar data source
}
