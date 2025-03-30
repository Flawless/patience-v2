variable "k8s_cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate (base64 encoded)"
  type        = string
  sensitive   = true
}

variable "k8s_client_certificate" {
  description = "Kubernetes client certificate (base64 encoded)"
  type        = string
  sensitive   = true
}

variable "k8s_client_key" {
  description = "Kubernetes client key (base64 encoded)"
  type        = string
  sensitive   = true
}
