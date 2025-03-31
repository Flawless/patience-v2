# Kubernetes Token Authentication

This Terraform configuration establishes service accounts with token-based authentication for
Kubernetes.

## Overview

- Creates service accounts with appropriate RBAC roles
- Designates the default namespace as a sandbox for development
- Provides commands to obtain authentication tokens

## Configuration Structure

Configuration is organized around service accounts:

```hcl
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
```

## Usage

### Initial Setup

```bash
tofu init
tofu apply
```

### Using Tokens with Terraform

Example provider configuration using tokens:

```terraform
provider "kubernetes" {
  host                   = module.k8s_config.k8s_config.host
  token                  = var.k8s_token  # From service account
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
}
```

Get token commands:

```bash
# Source directly into an environment variable
export TF_VAR_k8s_token=$(eval $(terraform output -raw admin_token_command))
```

## Service Account Permissions

- **admin-user**: Full cluster admin access plus infrastructure admin capabilities
- **developer-user**: Read-only cluster access plus full access to default namespace

## Token Rotation

Tokens expire after 1 hour for security. Generate fresh tokens as needed using the output commands.
