output "namespace" {
  description = "Namespace where MinIO Operator is deployed"
  value       = var.namespace
}

output "operator_service_name" {
  description = "Name of the MinIO Operator service"
  value       = "${kubernetes_service.minio_operator.metadata[0].name}.${var.namespace}.svc.cluster.local:4221"
}

output "sts_service_name" {
  description = "Name of the MinIO STS service"
  value       = "${kubernetes_service.minio_operator_sts.metadata[0].name}.${var.namespace}.svc.cluster.local:4223"
}

output "operator_service_account" {
  description = "Service account used by the MinIO Operator"
  value       = kubernetes_service_account.minio_operator.metadata[0].name
}

output "operator_cluster_role" {
  description = "Cluster role used by the MinIO Operator"
  value       = kubernetes_cluster_role.minio_operator.metadata[0].name
}
