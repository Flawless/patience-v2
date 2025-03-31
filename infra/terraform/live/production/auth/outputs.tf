output "admin_token_command" {
  description = "Command to get admin service account token"
  value       = module.k8s_auth.token_commands["admin-user"]
}

output "developer_token_command" {
  description = "Command to get developer service account token"
  value       = module.k8s_auth.token_commands["developer-user"]
}

output "sandbox_namespace" {
  description = "Namespace used for development experiments"
  value       = "default"
}

output "export_commands" {
  description = "Commands to export tokens as environment variables"
  value       = module.k8s_auth.export_commands
}
