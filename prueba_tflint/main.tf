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

# ⚠️ Módulo sin versión especificada
module "example_module" {
  source = "terraform-google-modules/network/google"
  # ⚠️ Falta version = "x.x.x"

  project_id   = var.project_id
  network_name = "test-network"
  subnets      = ["test-subnet"]
}

# Compute Engine Instance con machine type válido
resource "google_compute_instance" "demo_vm" {
  for_each     = toset(var.machine_type)
  name         = "vm-${each.key}"
  machine_type = each.key # ⚠️ Contiene "e2-mega-ultra-fake" que no existe
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }
}

# ⚠️ Nombre inconsistente (no sigue naming convention)
#tfsec:ignore:google-compute-enable-shielded-vm-im
#tfsec:ignore:google-compute-enable-shielded-vm-vtpm
#tfsec:ignore:google-compute-no-project-wide-ssh-keys
resource "google_compute_instance" "BadNameVM" {
  name         = "bad-name-vm"
  machine_type = "n1-standard-1"
  zone         = var.zone

  #tfsec:ignore:google-compute-vm-disk-encryption-customer-key
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }
}
