# --- Proxy-Only Subnet (REQUIRED for Regional ALB) ---
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "regional-proxy-subnet"
  ip_cidr_range = "10.0.50.0/24" # Ensure this doesn't conflict with existing default subnets
  region        = var.region
  network       = "default"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

# --- Firewall Rules (Default Network) ---
# Allow HTTP traffic to the instances from Google's Load Balancer Health Checks
resource "google_compute_firewall" "allow_health_check" {
  name    = "allow-lb-health-check"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  # These specific CIDR blocks are required by GCP for LB health checks
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
    "10.0.50.0/24"     # MUST allow traffic from the new proxy-only subnet!
    ]
  target_tags   = ["nginx-server"]
}

# Allow SSH via Google Identity-Aware Proxy (IAP) for troubleshooting
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["nginx-server"]
}

# --- Instance Template ---
resource "google_compute_instance_template" "nginx_template" {
  name_prefix  = "nginx-template-"
  machine_type = "e2-micro"
  tags         = ["nginx-server"]

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
    # No public IP assigned; traffic flows through the Load Balancer
  }

  # Install NGINX and set up a custom index page on boot
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Traffic successfully routed via GCP Application Load Balancer!</h1>" > /var/www/html/index.html
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

# --- Managed Instance Group (MIG) ---
resource "google_compute_instance_group_manager" "nginx_mig" {
  name               = "nginx-mig"
  base_instance_name = "nginx"
  zone               = var.zone

  version {
    instance_template = google_compute_instance_template.nginx_template.id
  }

  named_port {
    name = "http"
    port = 80
  }

  target_size = 2
}

