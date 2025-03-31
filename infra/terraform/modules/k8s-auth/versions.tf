terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    kubernetes = {
      source  = "registry.opentofu.org/hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
  }
}
