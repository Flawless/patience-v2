terraform {
  required_version = ">= 1.0.0"
  required_providers {
    kubernetes = {
      source  = "registry.opentofu.org/hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
  }
}

module "k8s_config" {
  source = "../../config"
}

provider "kubernetes" {
  host                   = module.k8s_config.k8s_config.host
  token                  = var.k8s_token
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
}

module "minio_operator" {
  source = "../../../../modules/minio-operator"

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
  
  # Set replicas to 1 for single-node cluster to avoid anti-affinity issues
  replicas = 1
  
  # Disable pod anti-affinity to ensure pod can be scheduled on the single node
  enable_pod_anti_affinity = false
}
