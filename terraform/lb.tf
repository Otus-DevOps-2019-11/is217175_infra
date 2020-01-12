resource "google_compute_instance_group" "reddit-webservers" {
  name      = "webservers"
  zone      = var.zone
  instances = google_compute_instance.app[*].self_link

  named_port {
    name = var.app_named_port.name
    port = var.app_named_port.port
  }
}

resource "google_compute_health_check" "reddit-healthcheck" {
  name               = "reddit-healthcheck"
  check_interval_sec = 5
  healthy_threshold  = 2
  timeout_sec        = 5

  http_health_check {
    port = var.app_named_port.port
  }
}

resource "google_compute_backend_service" "reddit-backend" {
  name                  = "redit-backend"
  health_checks         = [google_compute_health_check.reddit-healthcheck.self_link]
  load_balancing_scheme = "EXTERNAL"
  port_name             = var.app_named_port.name
  protocol              = "HTTP"
  timeout_sec           = 10

  backend {
    group = google_compute_instance_group.reddit-webservers.self_link
  }
}

resource "google_compute_url_map" "reddit-urlmap" {
  name            = "reddit-urlmap"
  default_service = google_compute_backend_service.reddit-backend.self_link
}

resource "google_compute_target_http_proxy" "reddit-http-proxy" {
  name    = "reddit-http-proxy"
  url_map = google_compute_url_map.reddit-urlmap.self_link
}

resource "google_compute_global_forwarding_rule" "reddit-forward-rule" {
  name                  = "reddit-forward-rule"
  target                = google_compute_target_http_proxy.reddit-http-proxy.self_link
  load_balancing_scheme = "EXTERNAL"
  port_range            = var.external_port
  ip_protocol           = "TCP"
}
