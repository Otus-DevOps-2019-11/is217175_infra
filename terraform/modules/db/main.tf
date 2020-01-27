resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["reddit-db"]
  labels       = var.labels
  boot_disk {
    initialize_params {
      image = var.db_disk_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

resource "null_resource" "db" {
  count = var.deploy ? 1 : 0
  connection {
    type        = "ssh"
    host        = google_compute_instance.db.network_interface.0.access_config.0.nat_ip
    user        = "appuser"
    agent       = false
    private_key = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/127.0.0.1/${google_compute_instance.db.network_interface.0.network_ip}/' /etc/mongod.conf",
      "sudo systemctl restart mongod.service"
    ]
  }
}

resource "google_compute_firewall" "firewall-mongo" {
  name    = "allow-mongo-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
  direction   = "INGRESS"
  source_tags = ["reddit-db"]
  target_tags = ["reddit-app"]
}
