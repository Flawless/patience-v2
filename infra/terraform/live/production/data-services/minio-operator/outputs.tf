output "namespace" {
  description = "Namespace where MinIO Operator is deployed"
  value       = module.minio_operator.namespace
}

output "operator_service_name" {
  description = "Name of the MinIO Operator service"
  value       = module.minio_operator.operator_service_name
}
