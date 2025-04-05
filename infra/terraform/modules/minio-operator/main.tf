resource "kubernetes_namespace" "minio_operator" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace

    labels = {
      "pod-security.kubernetes.io/enforce"         = "restricted"
      "pod-security.kubernetes.io/enforce-version" = "latest"
      "pod-security.kubernetes.io/audit"           = "restricted"
      "pod-security.kubernetes.io/audit-version"   = "latest"
      "pod-security.kubernetes.io/warn"            = "restricted"
      "pod-security.kubernetes.io/warn-version"    = "latest"
    }
  }
}

locals {
  tenant_crd_content        = file("${path.module}/crds/minio.min.io_tenants.yaml")
  policybinding_crd_content = file("${path.module}/crds/sts.min.io_policybindings.yaml")

  tenant_crd        = yamldecode(local.tenant_crd_content)
  policybinding_crd = yamldecode(local.policybinding_crd_content)
}

resource "kubernetes_manifest" "tenant_crd" {
  manifest = local.tenant_crd

  computed_fields = ["metadata.annotations", "metadata.labels", "spec.names.shortNames"]

  field_manager {
    force_conflicts = true
  }

  timeouts {
    create = "2m"
    update = "2m"
  }
}

resource "kubernetes_manifest" "policybinding_crd" {
  manifest = local.policybinding_crd

  computed_fields = ["metadata.annotations", "metadata.labels", "spec.names.shortNames"]

  field_manager {
    force_conflicts = true
  }

  timeouts {
    create = "2m"
    update = "2m"
  }
}

resource "kubernetes_service_account" "minio_operator" {
  metadata {
    name      = "minio-operator"
    namespace = var.namespace

    annotations = {
      "operator.min.io/authors" = "MinIO, Inc."
      "operator.min.io/license" = "AGPLv3"
      "operator.min.io/support" = "https://subnet.min.io"
      "operator.min.io/version" = var.operator_version
    }

    labels = {
      "app.kubernetes.io/name"     = "operator"
      "app.kubernetes.io/instance" = "minio-operator"
    }
  }
  depends_on = [kubernetes_namespace.minio_operator]
}

resource "kubernetes_cluster_role" "minio_operator" {
  metadata {
    name = "minio-operator-role"

    annotations = {
      "operator.min.io/authors" = "MinIO, Inc."
      "operator.min.io/license" = "AGPLv3"
      "operator.min.io/support" = "https://subnet.min.io"
      "operator.min.io/version" = var.operator_version
    }

    labels = {
      "app.kubernetes.io/name"     = "operator"
      "app.kubernetes.io/instance" = "minio-operator"
    }
  }

  # Rules from the cluster-role.yaml
  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["get", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
    verbs      = ["get", "update", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "nodes"]
    verbs      = ["get", "watch", "list"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "events", "configmaps"]
    verbs      = ["get", "watch", "create", "list", "delete", "deletecollection", "update", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "watch", "create", "update", "list", "delete", "deletecollection"]
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "deployments", "deployments/finalizers"]
    verbs      = ["get", "create", "list", "patch", "watch", "update", "delete"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "create", "list", "patch", "watch", "update", "delete"]
  }

  rule {
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests", "certificatesigningrequests/approval", "certificatesigningrequests/status"]
    verbs      = ["update", "create", "get", "delete", "list"]
  }

  rule {
    api_groups     = ["certificates.k8s.io"]
    resources      = ["signers"]
    resource_names = ["kubernetes.io/legacy-unknown", "kubernetes.io/kube-apiserver-client", "kubernetes.io/kubelet-serving", "beta.eks.amazonaws.com/app-serving"]
    verbs          = ["approve", "sign"]
  }

  rule {
    api_groups = ["authentication.k8s.io"]
    resources  = ["tokenreviews"]
    verbs      = ["create"]
  }

  rule {
    api_groups = ["minio.min.io", "sts.min.io", "job.min.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["min.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["monitoring.coreos.com"]
    resources  = ["prometheuses"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["get", "update", "create"]
  }

  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["create", "delete", "get", "list", "patch", "update", "deletecollection"]
  }
}

resource "kubernetes_cluster_role_binding" "minio_operator" {
  metadata {
    name = "minio-operator-binding"

    annotations = {
      "operator.min.io/authors" = "MinIO, Inc."
      "operator.min.io/license" = "AGPLv3"
      "operator.min.io/support" = "https://subnet.min.io"
      "operator.min.io/version" = var.operator_version
    }

    labels = {
      "app.kubernetes.io/name"     = "operator"
      "app.kubernetes.io/instance" = "minio-operator"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.minio_operator.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.minio_operator.metadata[0].name
    namespace = var.namespace
  }
}

resource "kubernetes_deployment" "minio_operator" {
  metadata {
    name      = "minio-operator"
    namespace = var.namespace

    annotations = {
      "operator.min.io/authors" = "MinIO, Inc."
      "operator.min.io/license" = "AGPLv3"
      "operator.min.io/support" = "https://subnet.min.io"
      "operator.min.io/version" = var.operator_version
    }

    labels = {
      "app.kubernetes.io/instance" = "minio-operator"
      "app.kubernetes.io/name"     = "operator"
    }
  }

  spec {
    replicas = var.replicas

    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        name = "minio-operator"
      }
    }

    template {
      metadata {
        labels = {
          name                         = "minio-operator"
          "app.kubernetes.io/instance" = "minio-operator"
          "app.kubernetes.io/name"     = "operator"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.minio_operator.metadata[0].name

        container {
          name              = "minio-operator"
          image             = var.operator_image
          args              = ["controller"]
          image_pull_policy = "IfNotPresent"

          env {
            name  = "WATCHED_NAMESPACE"
            value = var.watched_namespace
          }

          env {
            name  = "OPERATOR_NAMESPACE"
            value = var.namespace
          }

          resources {
            requests = {
              cpu                 = lookup(var.operator_resources.requests, "cpu", "200m")
              memory              = lookup(var.operator_resources.requests, "memory", "256Mi")
              "ephemeral-storage" = lookup(var.operator_resources.requests, "ephemeral-storage", "500Mi")
            }
            limits = var.operator_resources.limits
          }

          security_context {
            run_as_user                = 1000
            run_as_group               = 1000
            run_as_non_root            = true
            allow_privilege_escalation = false

            capabilities {
              drop = ["ALL"]
            }

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        dynamic "affinity" {
          for_each = var.enable_pod_anti_affinity ? [1] : []
          content {
            pod_anti_affinity {
              required_during_scheduling_ignored_during_execution {
                label_selector {
                  match_expressions {
                    key      = "name"
                    operator = "In"
                    values   = ["minio-operator"]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_cluster_role_binding.minio_operator,
    kubernetes_manifest.tenant_crd,
    kubernetes_manifest.policybinding_crd
  ]
}

resource "kubernetes_service" "minio_operator" {
  metadata {
    name      = "operator" # Important: keep this name as "operator"
    namespace = var.namespace

    annotations = {
      "operator.min.io/authors" = "MinIO, Inc."
      "operator.min.io/license" = "AGPLv3"
      "operator.min.io/support" = "https://subnet.min.io"
      "operator.min.io/version" = var.operator_version
    }

    labels = {
      name                         = "minio-operator"
      "app.kubernetes.io/instance" = "minio-operator"
      "app.kubernetes.io/name"     = "operator"
    }
  }

  spec {
    selector = {
      name     = "minio-operator"
      operator = "leader"
    }

    port {
      port = 4221
      name = "http"
    }

    type = "ClusterIP"
  }

  # Remove dependency on kubernetes_deployment.minio_operator to break circular dependency
  depends_on = [
    kubernetes_namespace.minio_operator,
    kubernetes_cluster_role_binding.minio_operator
  ]
}

resource "kubernetes_service" "minio_operator_sts" {
  metadata {
    name      = "sts" # Important: keep this name as "sts"
    namespace = var.namespace

    annotations = {
      "operator.min.io/authors" = "MinIO, Inc."
      "operator.min.io/license" = "AGPLv3"
      "operator.min.io/support" = "https://subnet.min.io"
      "operator.min.io/version" = var.operator_version
    }

    labels = {
      name = "minio-operator"
    }
  }

  spec {
    selector = {
      name = "minio-operator"
    }

    port {
      port        = 4223
      target_port = 4223
      name        = "https"
    }

    type = "ClusterIP"
  }

  # Remove dependency on kubernetes_deployment.minio_operator to break circular dependency
  depends_on = [
    kubernetes_namespace.minio_operator,
    kubernetes_cluster_role_binding.minio_operator
  ]
}
