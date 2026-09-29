# --- Outputs ---
output "load_balancer_ip" {
  description = "The public IP address of the Application Load Balancer"
  value       = google_compute_global_forwarding_rule.nginx_forwarding_rule.ip_address
}