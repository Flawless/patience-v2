variable "k8s_token" {
  description = "Kubernetes authentication token"
  type        = string
  sensitive   = true
}

variable "k8s_cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate (base64 encoded)"
  type        = string
  sensitive   = true
}
