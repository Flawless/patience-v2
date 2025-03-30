variable "namespace" {
  description = "Namespace to deploy Postgres Operator"
  type        = string
  default     = "postgres-operator"
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = true
}

variable "operator_image" {
  description = "Docker image for Postgres Operator"
  type        = string
  default     = "ghcr.io/zalando/postgres-operator:v1.14.0"
}

variable "spilo_image" {
  description = "Docker image for Spilo (Postgres pods)"
  type        = string
  default     = "ghcr.io/zalando/spilo-17:4.0-p2"
}

variable "operator_resources" {
  description = "Resources for the Postgres Operator pod"
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    requests = {
      cpu    = "100m"
      memory = "250Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "500Mi"
    }
  }
}

variable "watched_namespace" {
  description = "Namespace to watch for Postgres clusters (empty defaults to operator namespace, * for all namespaces)"
  type        = string
  default     = "*"
}

variable "enable_crd_registration" {
  description = "Whether to register CRDs or assume they're already registered"
  type        = bool
  default     = true
}

variable "enable_postgres_team_crd" {
  description = "Whether to enable the PostgresTeam CRD"
  type        = bool
  default     = false
}

variable "enable_database_access" {
  description = "Enable or disable the database access from the operator"
  type        = bool
  default     = true
}

variable "enable_teams_api" {
  description = "Enable or disable users sync with Teams API"
  type        = bool
  default     = false
}

variable "teams_api_url" {
  description = "URL of the Teams API service"
  type        = string
  default     = "http://fake-teams-api.default.svc.cluster.local"
}

variable "enable_master_load_balancer" {
  description = "Whether to enable master load balancer by default"
  type        = bool
  default     = false
}

variable "enable_replica_load_balancer" {
  description = "Whether to enable replica load balancer by default"
  type        = bool
  default     = false
}

variable "min_instances" {
  description = "Minimum number of instances in a cluster (overridden by manifest if specified)"
  type        = number
  default     = -1
}

variable "max_instances" {
  description = "Maximum number of instances in a cluster (overridden by manifest if specified)"
  type        = number
  default     = -1
}

