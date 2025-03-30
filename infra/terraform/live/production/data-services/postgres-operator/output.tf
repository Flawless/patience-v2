output "postgres_operator_namespace" {
  description = "Namespace where the Postgres Operator is deployed"
  value       = module.postgres_operator.namespace
}

output "postgres_operator_service_name" {
  description = "Service name of the Postgres Operator"
  value       = module.postgres_operator.operator_service_name
}

output "postgres_operator_api_endpoint" {
  description = "Internal API endpoint of the Postgres Operator"
  value       = module.postgres_operator.operator_api_endpoint
}

output "operator_service_account" {
  description = "Service account used by the Postgres Operator"
  value       = module.postgres_operator.operator_service_account
}
