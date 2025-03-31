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
  source = "../config"
}

provider "kubernetes" {
  host                   = module.k8s_config.k8s_config.host
  token                  = var.k8s_token
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
}

locals {
  service_accounts = {
    "admin-user" = {
      namespace = "kube-system",
      cluster_roles = ["cluster-admin", "infrastructure-admin"],
      namespace_roles = {}
    },
    "developer-user" = {
      namespace = "kube-system",
      cluster_roles = ["cluster-viewer"],
      namespace_roles = {
        "default" = ["default-admin"]
      }
    }
  }
  
  cluster_roles = {
    "infrastructure-admin" = {
      rules = [
        {
          api_groups = ["acid.zalan.do"]
          resources  = ["postgresqls", "postgresqls/status", "operatorconfigurations", "postgresteams"]
          verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
        },
        {
          api_groups = ["monitoring.coreos.com"]
          resources  = ["prometheuses", "alertmanagers", "servicemonitors", "podmonitors"]
          verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
        },
        {
          api_groups = [""]
          resources  = ["secrets", "configmaps"]
          resource_names = ["terraform-state"]
          verbs      = ["get", "update", "patch"]
        }
      ]
    },
    "cluster-viewer" = {
      rules = [
        {
          api_groups = [""]
          resources  = ["pods", "services", "configmaps", "namespaces", "nodes", "persistentvolumeclaims"]
          verbs      = ["get", "list", "watch"]
        },
        {
          api_groups = ["apps"]
          resources  = ["deployments", "statefulsets", "daemonsets", "replicasets"]
          verbs      = ["get", "list", "watch"]
        },
        {
          api_groups = ["batch"]
          resources  = ["jobs", "cronjobs"]
          verbs      = ["get", "list", "watch"]
        },
        {
          api_groups = ["networking.k8s.io"]
          resources  = ["ingresses", "networkpolicies"]
          verbs      = ["get", "list", "watch"]
        }
      ]
    }
  }
  
  namespace_roles = {
    "default-admin" = {
      namespace = "default",
      rules = [
        {
          api_groups = ["*"]
          resources  = ["*"]
          verbs      = ["*"]
        }
      ]
    }
  }
}

module "k8s_auth" {
  source = "../../../modules/k8s-auth"
  
  service_accounts = local.service_accounts
  cluster_roles = local.cluster_roles
  namespace_roles = local.namespace_roles
  common_labels = module.k8s_config.common_labels
}
