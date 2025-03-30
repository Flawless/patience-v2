output "namespace" {
  description = "Namespace where Postgres Operator is deployed"
  value       = var.namespace
}

output "operator_service_name" {
  description = "Service name of the Postgres Operator"
  value       = kubernetes_service.postgres_operator.metadata[0].name
}

output "operator_service_account" {
  description = "Service account used by the Postgres Operator"
  value       = kubernetes_service_account.postgres_operator.metadata[0].name
}

output "operator_deployment_name" {
  description = "Deployment name of the Postgres Operator"
  value       = kubernetes_deployment.postgres_operator.metadata[0].name
}

output "operator_api_endpoint" {
  description = "Internal API endpoint of the Postgres Operator"
  value       = "${kubernetes_service.postgres_operator.metadata[0].name}.${var.namespace}.svc.cluster.local:8080"
}
