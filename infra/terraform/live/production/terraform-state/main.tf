terraform {
  backend "kubernetes" {
    config_path   = "../../../kubeconfig.yaml"
    namespace     = "terraform"
    secret_suffix = "terraform-state"
  }
}

module "k8s_config" {
  source = "../config"
}

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

provider "kubernetes" {
  host                   = module.k8s_config.k8s_config.host
  token                  = var.k8s_token
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
}

resource "kubernetes_namespace" "terraform_state" {
  metadata {
    name = "terraform"
    labels = {
      "managed-by" = "terraform"
      "purpose"    = "state-storage"
    }
  }
}

output "backend_config" {
  value = {
    namespace = kubernetes_namespace.terraform_state.metadata[0].name
  }
}
