terraform {
  required_version = ">= 1.0.0"
  required_providers {
    kubernetes = {
      source  = "registry.opentofu.org/hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
  }
}

# Provider configuration with proper authentication
provider "kubernetes" {
  # Use either host/token or config_path, but not both
  client_certificate     = base64decode(var.k8s_client_certificate)
  client_key             = base64decode(var.k8s_client_key)
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
}

# Directly use the module with environment-specific values
module "postgres_operator" {
  source = "../../../../modules/postgres-operator"

  # Core settings - use specific values directly
  namespace         = "postgres-operator"
  watched_namespace = "*" # Watch all namespaces

  # Image settings
  operator_image = "ghcr.io/zalando/postgres-operator:v1.14.0"
  spilo_image    = "ghcr.io/zalando/spilo-17:4.0-p2"

  # Feature flags
  enable_postgres_team_crd     = true
  enable_master_load_balancer  = false
  enable_replica_load_balancer = false

  # Resource settings
  operator_resources = {
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
