# --- Outputs ---
output "load_balancer_ip" {
  description = "The regional public IP address of the Application Load Balancer"
  value       = google_compute_forwarding_rule.nginx_forwarding_rule.ip_address
}