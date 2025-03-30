terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
  # When ready to migrate to Kubernetes backend:
  # backend "kubernetes" {
  #   secret_suffix    = "postgres-operator-state"
  #   namespace        = "terraform"
  #   in_cluster_config = true
  # }
}
