output "service_accounts" {
  description = "Map of service account names to their namespaces"
  value = { for k, v in kubernetes_service_account.accounts : k => {
    name      = v.metadata[0].name
    namespace = v.metadata[0].namespace
  } }
}

output "token_commands" {
  description = "Commands to generate tokens for each service account"
  value = { for k, v in kubernetes_service_account.accounts : k =>
    "kubectl create token ${v.metadata[0].name} -n ${v.metadata[0].namespace} --duration=86400s"
  }
}

output "export_commands" {
  description = "Commands to export tokens as environment variables"
  value = { for k, v in kubernetes_service_account.accounts : k =>
    "export TF_VAR_k8s_token=$(kubectl create token ${v.metadata[0].name} -n ${v.metadata[0].namespace} --duration=86400s)"
  }
}
