variable "name" {
  description = "Name of the MinIO tenant"
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy MinIO tenant"
  type        = string
}

variable "image" {
  description = "MinIO server image"
  type        = string
  default     = "minio/minio:RELEASE.2025-04-03T14-56-28Z"
}

variable "service_account" {
  description = "Service account for the MinIO tenant"
  type        = string
  default     = "minio-tenant"
}

variable "servers" {
  description = "Number of MinIO server instances"
  type        = number
  default     = 4
}

variable "volumes_per_server" {
  description = "Number of volumes per MinIO server"
  type        = number
  default     = 4
}

variable "capacity_per_volume" {
  description = "Capacity per volume (e.g., '10Gi')"
  type        = string
  default     = "10Gi"
}

variable "storage_class" {
  description = "Storage class for MinIO volumes"
  type        = string
  default     = "standard"
}

variable "resources" {
  description = "Resources for MinIO tenant pods"
  type = object({
    requests = map(string)
    limits   = map(string)
  })
  default = {
    requests = {
      cpu    = "250m"
      memory = "2Gi"
    }
    limits = {
      cpu    = "500m"
      memory = "4Gi"
    }
  }
}

variable "access_key" {
  description = "Access key for the MinIO root user. If not provided, a random key will be generated."
  type        = string
  default     = ""
  sensitive   = true
}

variable "secret_key" {
  description = "Secret key for the MinIO root user. If not provided, a random key will be generated."
  type        = string
  default     = ""
  sensitive   = true
}

variable "existing_secret_name" {
  description = "Name of an existing secret to use for credentials. If provided, access_key and secret_key are ignored."
  type        = string
  default     = ""
}

variable "existing_secret_namespace" {
  description = "Namespace of the existing secret to use for credentials. Defaults to the same namespace as the tenant."
  type        = string
  default     = ""
}

variable "existing_secret_access_key" {
  description = "Key in the existing secret that contains the access key. Default is 'accesskey'."
  type        = string
  default     = "accesskey"
}

variable "existing_secret_secret_key" {
  description = "Key in the existing secret that contains the secret key. Default is 'secretkey'."
  type        = string
  default     = "secretkey"
}

variable "generate_credentials" {
  description = "Whether to generate random credentials if not provided"
  type        = bool
  default     = true
}

variable "enable_console" {
  description = "Whether to enable MinIO Console UI"
  type        = bool
  default     = true
}

variable "console_annotations" {
  description = "Annotations for the MinIO Console service"
  type        = map(string)
  default     = {}
}

variable "service_annotations" {
  description = "Annotations for the MinIO service"
  type        = map(string)
  default     = {}
}

variable "expose_services" {
  description = "Whether to expose MinIO services"
  type        = bool
  default     = true
}

variable "tls_enabled" {
  description = "Whether to enable TLS for the tenant"
  type        = bool
  default     = false
}

variable "certificate_secret" {
  description = "Name of the secret containing TLS certificate (required if tls_enabled is true)"
  type        = string
  default     = ""
}

variable "request_autoCert" {
  description = "Whether to request automatic TLS certificate generation"
  type        = bool
  default     = false
}

variable "expose_prometheus" {
  description = "Whether to expose Prometheus metrics endpoint"
  type        = bool
  default     = true
}

variable "service_type" {
  description = "Type of service to create (ClusterIP, NodePort, LoadBalancer)"
  type        = string
  default     = "ClusterIP"
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "pod_annotations" {
  description = "Annotations to apply to tenant pods"
  type        = map(string)
  default     = {}
}

variable "pod_priority_class_name" {
  description = "Priority class name for tenant pods"
  type        = string
  default     = ""
} 