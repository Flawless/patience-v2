# Kubernetes Authentication Module

This module provides a framework for setting up token-based authentication for Kubernetes using service accounts and RBAC.

## Features

- Creates service accounts with appropriate RBAC permissions
- Implements a service account-centric role binding model
- Optionally labels the default namespace as a development/experimentation space
- Provides token generation commands for authentication

## Usage

```hcl
module "k8s_auth" {
  source = "../../modules/k8s-auth"

  # Required: Define service accounts and their roles
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

  # Required: Define cluster roles
  cluster_roles = {
    "infrastructure-admin" = {
      rules = [
        {
          api_groups = ["acid.zalan.do"]
          resources  = ["postgresqls", "postgresqls/status", "operatorconfigurations"]
          verbs      = ["*"]
        }
      ]
    },
    "cluster-viewer" = {
      rules = [
        {
          api_groups = [""]
          resources  = ["pods", "services", "configmaps", "namespaces"]
          verbs      = ["get", "list", "watch"]
        }
      ]
    }
  }

  # Required: Define namespace roles
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

  # Required: Define common labels
  common_labels = {
    "managed-by" = "terraform",
    "component"  = "auth-system"
  }
}
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| service_accounts | Map of service accounts with their assigned roles | map(object) | (required) |
| cluster_roles | Map of cluster roles and their rules | map(object) | (required) |
| namespace_roles | Map of namespace roles and their rules | map(object) | (required) |
| common_labels | Common labels to apply to all resources | map(string) | (required) |
| config_default_namespace | Whether to configure default namespace as sandbox | bool | true |

## Outputs

| Name | Description |
|------|-------------|
| service_accounts | Map of service account names to their namespaces |
| token_commands | Commands to generate tokens for each service account |
| export_commands | Commands to export tokens as environment variables |

## Example: Using Generated Tokens

After applying the module, you can get token generation commands:

```bash
# Get command to create admin token
terraform output -raw module.k8s_auth.token_commands.admin-user

# Export token directly
$(terraform output -raw module.k8s_auth.export_commands.admin-user)
```

Then use in your provider configuration:

```hcl
provider "kubernetes" {
  host                   = "https://your-cluster-endpoint"
  token                  = var.k8s_token  # From environment
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
}
```
