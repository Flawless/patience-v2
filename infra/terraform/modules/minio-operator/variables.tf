variable "namespace" {
  description = "Namespace to deploy MinIO Operator"
  type        = string
  default     = "minio-operator"
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = true
}

variable "operator_image" {
  description = "Docker image for MinIO Operator"
  type        = string
  default     = "minio/operator:v7.0.1"
}

variable "operator_version" {
  description = "Version of the MinIO Operator (used in annotations)"
  type        = string
  default     = "v7.0.1"
}

variable "operator_resources" {
  description = "Resources for the MinIO Operator pod"
  type = object({
    requests = map(string)
    limits   = map(string)
  })
  default = {
    requests = {
      cpu               = "200m"
      memory            = "256Mi"
      ephemeral-storage = "500Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "500Mi"
    }
  }
}

variable "watched_namespace" {
  description = "Namespace to watch for MinIO tenants (empty defaults to operator namespace, \"\" for all namespaces)"
  type        = string
  default     = ""
}

variable "enable_pod_anti_affinity" {
  description = "Whether to enable pod anti-affinity for the MinIO Operator pods"
  type        = bool
  default     = true
}

variable "replicas" {
  description = "Number of MinIO Operator replicas to deploy"
  type        = number
  default     = 2
}
