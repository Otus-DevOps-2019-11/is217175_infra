terraform {
  required_version = "0.12.19"
}

provider "google" {
  version = "3.0.0"
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "app" {
  count        = var.instance_count
  name         = "reddit-app-${count.index}"
  machine_type = "f1-micro"
  zone         = var.zone
  tags         = ["reddit-app"]
  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    host        = self.network_interface[0].access_config[0].nat_ip
    user        = "appuser"
    agent       = false
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall-puma" {
  name    = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  direction     = "INGRESS"
  priority      = "1000"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}

resource "google_compute_project_metadata_item" "default" {
  key   = "ssh-keys"
  value = <<-EOT
    appuser1:${file(var.public_key_path)}
    appuser2:${file(var.public_key_path)}
    appuser3:${file(var.public_key_path)}
  EOT
}
