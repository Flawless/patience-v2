locals {
  common_labels = {
    "managed-by" = "terraform"
    "app.kubernetes.io/part-of" = "platform"
  }
}

output "common_labels" {
  description = "Common labels to apply to all resources"
  value       = local.common_labels
}
