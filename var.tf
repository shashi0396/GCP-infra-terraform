# --- Variables ---
variable "project_id" {
  description = "Your GCP Project ID"
  type        = string
  default     = "sunlit-loop-417711"
}

variable "region" {
  description = "Region for the Managed Instance Group"
  default     = "us-central1"
}

variable "zone" {
  description = "Zone for the Managed Instance Group"
  default     = "us-central1-a"
}