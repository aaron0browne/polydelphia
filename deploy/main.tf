variable "project" {
  default = "aaron0browne-164216"
}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-b"
}

variable "network" {
  default = "default"
}

provider "google" {
  project = "${var.project}"
  region  = "${var.region}"
}

data "google_compute_image" "polydelphia-web" {
  family = "polydelphia-web"
}

resource "google_compute_address" "polydelphia-external" {
  name = "polydelphia-external"
}

resource "google_compute_instance" "polydelphia-web" {
  name                    = "polydelphia-web"
  description             = "A Polydelphia web site server instance."
  machine_type            = "f1-micro"
  zone                    = "${var.zone}"
  metadata_startup_script = "${file("${path.module}/build/start.sh")}"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.polydelphia-web.self_link}"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = "${google_compute_address.polydelphia-external.address}"
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  labels {
    environment = "prod"
  }

  tags = ["polydelphia", "web"]
}

resource "google_compute_firewall" "polydelphia-web" {
  name    = "polydelphia-web"
  network = "${var.network}"
  description = "Allows web traffic to Polydelphia web servers."

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = ["polydelphia", "web"]
}

output "external-ip" {
  value = "${google_compute_address.polydelphia-external.address}"
}
