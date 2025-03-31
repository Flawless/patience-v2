locals {
  # Skip the namespace creation/management altogether
  # Just create roles and bindings
  
  # Generate cluster role bindings from service account mapping
  cluster_role_bindings = flatten([
    for sa_name, sa_config in var.service_accounts : [
      for role_name in sa_config.cluster_roles : {
        name = "${sa_name}-${role_name}"
        role_ref = {
          kind = "ClusterRole"
          name = role_name
        }
        subject = {
          kind      = "ServiceAccount"
          name      = sa_name
          namespace = sa_config.namespace
        }
      }
    ]
  ])
  
  # Generate namespace role bindings from service account mapping
  namespace_role_bindings = flatten([
    for sa_name, sa_config in var.service_accounts : [
      for namespace, roles in sa_config.namespace_roles : [
        for role_name in roles : {
          name = "${sa_name}-${role_name}"
          namespace = namespace
          role_ref = {
            kind = "Role"
            name = role_name
          }
          subject = {
            kind      = "ServiceAccount"
            name      = sa_name
            namespace = sa_config.namespace
          }
        }
      ]
    ]
  ])
}

# Create service accounts
resource "kubernetes_service_account" "accounts" {
  for_each = var.service_accounts
  
  metadata {
    name      = each.key
    namespace = each.value.namespace
    labels    = var.common_labels
  }
}

# Create cluster roles
resource "kubernetes_cluster_role" "roles" {
  for_each = var.cluster_roles
  
  metadata {
    name   = each.key
    labels = var.common_labels
  }
  
  dynamic "rule" {
    for_each = each.value.rules
    content {
      api_groups     = rule.value.api_groups
      resources      = rule.value.resources
      resource_names = lookup(rule.value, "resource_names", null)
      verbs          = rule.value.verbs
    }
  }
}

# Create namespace roles
resource "kubernetes_role" "roles" {
  for_each = var.namespace_roles
  
  metadata {
    name      = each.key
    namespace = each.value.namespace
    labels    = var.common_labels
  }
  
  dynamic "rule" {
    for_each = each.value.rules
    content {
      api_groups     = rule.value.api_groups
      resources      = rule.value.resources
      resource_names = lookup(rule.value, "resource_names", null)
      verbs          = rule.value.verbs
    }
  }
}

# Create cluster role bindings
resource "kubernetes_cluster_role_binding" "bindings" {
  for_each = { for binding in local.cluster_role_bindings : binding.name => binding }
  
  metadata {
    name   = each.key
    labels = var.common_labels
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = each.value.role_ref.kind
    name      = each.value.role_ref.name
  }
  
  subject {
    kind      = each.value.subject.kind
    name      = each.value.subject.name
    namespace = each.value.subject.namespace
  }
}

# Create namespace role bindings
resource "kubernetes_role_binding" "bindings" {
  for_each = { for binding in local.namespace_role_bindings : "${binding.namespace}-${binding.name}" => binding }
  
  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    labels    = var.common_labels
  }
  
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = each.value.role_ref.kind
    name      = each.value.role_ref.name
  }
  
  subject {
    kind      = each.value.subject.kind
    name      = each.value.subject.name
    namespace = each.value.subject.namespace
  }
}
