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

/*
resource "google_compute_health_check" "polydelphia-web" {
  name                = "polydelphia-web"
  description         = "Health check for Polydelphia web site servers."
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10                         # 50 seconds

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}

resource "google_compute_target_pool" "polydelphia-web" {
  name        = "polydelphia-web"
  description = "Target pool for Polydelphia web site servers."
}

resource "google_compute_instance_group_manager" "polydelphia-web" {
  name        = "polydelphia-web"
  description = "Instance group manager for Polydelphia web site servers."

  base_instance_name = "polydelphia-web"
  instance_template  = "${google_compute_instance_template.polydelphia-web.self_link}"
  update_strategy    = "NONE"
  zone               = "us-central1-a"

  target_pools = ["${google_compute_target_pool.polydelphia-web.self_link}"]
  target_size  = 1

  auto_healing_policies {
    health_check      = "${google_compute_health_check.polydelphia-web.self_link}"
    initial_delay_sec = 300
  }
}

resource "google_compute_backend_service" "polydelphia-web" {
  name        = "polydelphia-web"
  description = "Polydelphia web site service."
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10
  enable_cdn  = false

  backend {
    group = "${google_compute_instance_group_manager.polydelphia-web.instance_group}"
  }

  health_checks = ["${google_compute_health_check.default.self_link}"]
}
*/
