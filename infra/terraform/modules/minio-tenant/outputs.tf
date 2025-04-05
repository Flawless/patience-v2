output "tenant_name" {
  description = "Name of the MinIO tenant"
  value       = var.name
}

output "namespace" {
  description = "Namespace where the MinIO tenant is deployed"
  value       = var.namespace
}

output "service_name" {
  description = "Name of the MinIO service"
  value       = "${var.name}-hl-svc"
}

output "console_service_name" {
  description = "Name of the MinIO Console service"
  value       = "${var.name}-console"
}

output "endpoint" {
  description = "Endpoint for accessing MinIO (without protocol)"
  value       = "${var.name}-hl-svc.${var.namespace}.svc.cluster.local"
}

output "console_endpoint" {
  description = "Endpoint for accessing MinIO Console (without protocol)"
  value       = "${var.name}-console.${var.namespace}.svc.cluster.local"
}

output "access_key" {
  description = "Access key for the MinIO root user (only if not using existing secret)"
  value       = local.use_existing_secret ? null : local.access_key
  sensitive   = true
}

output "secret_key" {
  description = "Secret key for the MinIO root user (only if not using existing secret)"
  value       = local.use_existing_secret ? null : local.secret_key
  sensitive   = true
}

output "credentials_secret" {
  description = "Name of the secret containing MinIO credentials"
  value       = local.credentials_secret_name
}

output "using_existing_secret" {
  description = "Whether an existing secret is being used for credentials"
  value       = local.use_existing_secret
} 