terraform {
  required_version = ">= 1.0.0"
  required_providers {
    kubernetes = {
      source  = "registry.opentofu.org/hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
    random = {
      source  = "registry.opentofu.org/hashicorp/random"
      version = "~> 3.5.0"
    }
  }
}

locals {
  tenant_labels = merge(
    {
      "app"                          = "minio"
      "app.kubernetes.io/name"       = "minio"
      "app.kubernetes.io/instance"   = var.name
      "app.kubernetes.io/managed-by" = "terraform"
    },
    var.labels
  )
  
  # Determine credential source
  use_existing_secret = var.existing_secret_name != ""
  
  # Generate or use provided credentials if not using existing secret
  generate_access_key = !local.use_existing_secret && var.generate_credentials && var.access_key == ""
  generate_secret_key = !local.use_existing_secret && var.generate_credentials && var.secret_key == ""
  
  # Final credentials to use if we're creating our own secret
  access_key = local.generate_access_key ? random_password.access_key[0].result : var.access_key
  secret_key = local.generate_secret_key ? random_password.secret_key[0].result : var.secret_key
  
  # Secret name to use
  credentials_secret_name = local.use_existing_secret ? var.existing_secret_name : kubernetes_secret.minio_credentials[0].metadata[0].name
}

# Generate random credentials if needed
resource "random_password" "access_key" {
  count   = local.generate_access_key ? 1 : 0
  length  = 16
  special = false
}

resource "random_password" "secret_key" {
  count            = local.generate_secret_key ? 1 : 0
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create a secret for MinIO credentials if not using existing secret
resource "kubernetes_secret" "minio_credentials" {
  count = local.use_existing_secret ? 0 : 1
  
  metadata {
    name      = "${var.name}-credentials"
    namespace = var.namespace
    labels    = local.tenant_labels
  }

  data = {
    accesskey = local.access_key
    secretkey = local.secret_key
  }

  type = "Opaque"
}

# Create the MinIO Tenant custom resource
resource "kubernetes_manifest" "minio_tenant" {
  manifest = {
    apiVersion = "minio.min.io/v2"
    kind       = "Tenant"
    metadata = {
      name      = var.name
      namespace = var.namespace
      labels    = local.tenant_labels
    }
    spec = {
      image              = var.image
      serviceAccountName = var.service_account
      
      env = [
        {
          name = "MINIO_ROOT_USER"
          valueFrom = {
            secretKeyRef = {
              name = local.credentials_secret_name
              key  = local.use_existing_secret ? var.existing_secret_access_key : "accesskey"
            }
          }
        },
        {
          name = "MINIO_ROOT_PASSWORD"
          valueFrom = {
            secretKeyRef = {
              name = local.credentials_secret_name
              key  = local.use_existing_secret ? var.existing_secret_secret_key : "secretkey"
            }
          }
        }
      ]

      pools = [
        {
          name             = "pool-0"
          servers          = var.servers
          volumesPerServer = var.volumes_per_server
          volumeClaimTemplate = {
            metadata = {
              labels = local.tenant_labels
            }
            spec = {
              accessModes      = ["ReadWriteOnce"]
              storageClassName = var.storage_class
              resources = {
                requests = {
                  storage = var.capacity_per_volume
                }
              }
            }
          }
          resources = {
            requests = var.resources.requests
            limits   = var.resources.limits
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_secret.minio_credentials
  ]
} 