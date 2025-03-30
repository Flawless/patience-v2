terraform {
  required_providers {
    kubernetes = {
      source  = "registry.opentofu.org/hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

module "postgres_operator" {
  source = "../../modules/postgres-operator"

  namespace = "postgres-operator"

  # Uncomment any variables you want to override from defaults
  # watched_namespace = var.watched_namespace
  # operator_image = var.operator_image
  # spilo_image = var.spilo_image
  # enable_postgres_team_crd = var.enable_postgres_team_crd
}
