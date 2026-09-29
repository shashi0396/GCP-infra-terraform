# --- Regional External Application Load Balancer ---

# 1. Regional Health Check
resource "google_compute_region_health_check" "nginx_health_check" {
  name               = "nginx-regional-hc"
  region             = var.region
  check_interval_sec = 5
  timeout_sec        = 5

  http_health_check {
    port = 80
  }
}

# 2. Regional Backend Service (EXTERNAL_MANAGED)
resource "google_compute_region_backend_service" "nginx_backend" {
  name                  = "nginx-regional-backend"
  region                = var.region
  port_name             = "http"
  protocol              = "HTTP"
  health_checks         = [google_compute_region_health_check.nginx_health_check.id]
  
  # Crucial change for Regional External ALB
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group           = google_compute_instance_group_manager.nginx_mig.instance_group
    capacity_scaler = 1.0
    balancing_mode  = "UTILIZATION"
  }
}

# 3. Regional URL Map
resource "google_compute_region_url_map" "nginx_url_map" {
  name            = "nginx-regional-url-map"
  region          = var.region
  default_service = google_compute_region_backend_service.nginx_backend.id
}

# 4. Regional Target HTTP Proxy
resource "google_compute_region_target_http_proxy" "nginx_proxy" {
  name    = "nginx-regional-proxy"
  region  = var.region
  url_map = google_compute_region_url_map.nginx_url_map.id
}

# 5. Regional Forwarding Rule (Frontend IP)
resource "google_compute_forwarding_rule" "nginx_forwarding_rule" {
  name                  = "nginx-regional-forwarding-rule"
  region                = var.region
  target                = google_compute_region_target_http_proxy.nginx_proxy.id
  port_range            = "80"
  
  # Must match the backend service
  load_balancing_scheme = "EXTERNAL_MANAGED" 
  
  # Must be in the same network as the proxy-only subnet
  network               = "default"
}