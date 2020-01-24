output "db_addr" {
  value = google_compute_instance.db.network_interface.0.network_ip
}
