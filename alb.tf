# --- External Application Load Balancer ---
# 1. Health Check
resource "google_compute_health_check" "nginx_health_check" {
  name               = "nginx-health-check"
  check_interval_sec = 5
  timeout_sec        = 5

  http_health_check {
    port = 80
  }
}

# 2. Backend Service
resource "google_compute_backend_service" "nginx_backend" {
  name                  = "nginx-backend"
  port_name             = "http"
  protocol              = "HTTP"
  health_checks         = [google_compute_health_check.nginx_health_check.id]
  load_balancing_scheme = "EXTERNAL"

  backend {
    group = google_compute_instance_group_manager.nginx_mig.instance_group
  }
}

# 3. URL Map
resource "google_compute_url_map" "nginx_url_map" {
  name            = "nginx-url-map"
  default_service = google_compute_backend_service.nginx_backend.id
}

# 4. Target HTTP Proxy
resource "google_compute_target_http_proxy" "nginx_proxy" {
  name    = "nginx-proxy"
  url_map = google_compute_url_map.nginx_url_map.id
}

# 5. Global Forwarding Rule (Frontend IP)
resource "google_compute_global_forwarding_rule" "nginx_forwarding_rule" {
  name                  = "nginx-forwarding-rule"
  target                = google_compute_target_http_proxy.nginx_proxy.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
}

