resource "kubernetes_namespace" "postgres_operator" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_account" "postgres_operator" {
  metadata {
    name      = "postgres-operator"
    namespace = var.namespace
  }
  depends_on = [kubernetes_namespace.postgres_operator]
}

resource "kubernetes_cluster_role" "postgres_operator" {
  metadata {
    name = "postgres-operator"
  }

  rule {
    api_groups = ["acid.zalan.do"]
    resources  = ["postgresqls", "postgresqls/status", "operatorconfigurations"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = ["acid.zalan.do"]
    resources  = ["postgresteams"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["create", "get", "patch", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["create", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create", "delete", "get", "update", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
    verbs      = ["delete", "get", "list", "patch", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["get", "list", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["delete", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create"]
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["create", "delete", "get", "patch", "update"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "deployments"]
    verbs      = ["create", "delete", "get", "list", "patch", "update"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["cronjobs"]
    verbs      = ["create", "delete", "get", "list", "patch", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get"]
  }

  rule {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = ["create", "delete", "get"]
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts"]
    verbs      = ["get", "create"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["rolebindings"]
    verbs      = ["get", "create"]
  }
}

resource "kubernetes_cluster_role" "postgres_pod" {
  metadata {
    name = "postgres-pod"
  }

  rule {
    api_groups = [""]
    resources  = ["endpoints"]
    verbs      = ["create", "delete", "deletecollection", "get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "patch", "update", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["services"]
    verbs      = ["create"]
  }
}

resource "kubernetes_cluster_role_binding" "postgres_operator" {
  metadata {
    name = "postgres-operator"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.postgres_operator.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.postgres_operator.metadata[0].name
    namespace = var.namespace
  }
}

resource "kubernetes_config_map" "postgres_operator" {
  metadata {
    name      = "postgres-operator"
    namespace = var.namespace
  }

  data = {
    # General settings
    "docker_image"              = var.spilo_image
    "enable_crd_registration"   = tostring(var.enable_crd_registration)
    "enable_crd_validation"     = "true"
    "enable_shm_volume"         = "true"
    "etcd_host"                 = ""
    "kubernetes_use_configmaps" = "false"
    "max_instances"             = tostring(var.max_instances)
    "min_instances"             = tostring(var.min_instances)
    "resync_period"             = "30m"
    "repair_period"             = "5m"
    "workers"                   = "8"

    # API and access settings
    "api_port"                            = "8080"
    "cluster_domain"                      = "cluster.local"
    "cluster_labels"                      = "application:spilo"
    "cluster_name_label"                  = "cluster-name"
    "db_hosted_zone"                      = "db.example.com"
    "debug_logging"                       = "true"
    "enable_database_access"              = tostring(var.enable_database_access)
    "enable_teams_api"                    = tostring(var.enable_teams_api)
    "enable_postgres_team_crd"            = tostring(var.enable_postgres_team_crd)
    "enable_postgres_team_crd_superusers" = "false"
    "kubernetes_use_configmaps"           = "false"
    "oauth_token_secret_name"             = "postgresql-operator"
    "pam_role_name"                       = "zalandos"
    "pod_role_label"                      = "spilo-role"
    "postgres_superuser_teams"            = "postgres_superusers"
    "protected_role_names"                = "admin,cron_admin"
    "watched_namespace"                   = var.watched_namespace

    # Load balancer settings
    "enable_master_load_balancer"         = tostring(var.enable_master_load_balancer)
    "enable_replica_load_balancer"        = tostring(var.enable_replica_load_balancer)
    "enable_master_pooler_load_balancer"  = "false"
    "enable_replica_pooler_load_balancer" = "false"
    "external_traffic_policy"             = "Cluster"
    "master_dns_name_format"              = "{cluster}.{namespace}.{hostedzone}"
    "replica_dns_name_format"             = "{cluster}-repl.{namespace}.{hostedzone}"

    # Resource settings
    "default_cpu_limit"      = "1"
    "default_cpu_request"    = "100m"
    "default_memory_limit"   = "500Mi"
    "default_memory_request" = "100Mi"
    "min_cpu_limit"          = "250m"
    "min_memory_limit"       = "250Mi"

    # Postgres configuration
    "super_username"       = "postgres"
    "replication_username" = "standby"

    # Pod management
    "enable_pod_antiaffinity"                 = "false"
    "enable_pod_disruption_budget"            = "true"
    "enable_finalizers"                       = "false"
    "enable_init_containers"                  = "true"
    "enable_persistent_volume_claim_deletion" = "true"
    "enable_sidecars"                         = "true"
    "pod_deletion_wait_timeout"               = "10m"
    "pod_terminate_grace_period"              = "5m"

    # Timeouts
    "pod_label_wait_timeout"  = "10m"
    "ready_wait_interval"     = "3s"
    "ready_wait_timeout"      = "30s"
    "resource_check_interval" = "3s"
    "resource_check_timeout"  = "10m"

    # Teams API settings
    "team_admin_role"             = "admin"
    "team_api_role_configuration" = "log_statement:all"
    "teams_api_url"               = var.teams_api_url

    # Backup settings
    "logical_backup_docker_image" = "ghcr.io/zalando/postgres-operator/logical-backup:v1.14.0"
    "logical_backup_job_prefix"   = "logical-backup-"
    "logical_backup_provider"     = "s3"
    "logical_backup_schedule"     = "30 00 * * *"

    # Connection pooler
    "connection_pooler_image"                  = "registry.opensource.zalan.do/acid/pgbouncer:master-32"
    "connection_pooler_max_db_connections"     = "60"
    "connection_pooler_mode"                   = "transaction"
    "connection_pooler_default_cpu_request"    = "500m"
    "connection_pooler_default_memory_request" = "100Mi"
    "connection_pooler_default_cpu_limit"      = "1"
    "connection_pooler_default_memory_limit"   = "100Mi"

    # Version upgrades
    "major_version_upgrade_mode" = "manual"
    "minimal_major_version"      = "13"
    "target_major_version"       = "17"
  }

  depends_on = [kubernetes_namespace.postgres_operator]
}

resource "kubernetes_deployment" "postgres_operator" {
  metadata {
    name      = "postgres-operator"
    namespace = var.namespace

    labels = {
      application = "postgres-operator"
    }
  }

  spec {
    replicas = 1

    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        name = "postgres-operator"
      }
    }

    template {
      metadata {
        labels = {
          name = "postgres-operator"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.postgres_operator.metadata[0].name

        container {
          name  = "postgres-operator"
          image = var.operator_image

          resources {
            requests = {
              cpu    = var.operator_resources.requests.cpu
              memory = var.operator_resources.requests.memory
            }
            limits = {
              cpu    = var.operator_resources.limits.cpu
              memory = var.operator_resources.limits.memory
            }
          }

          security_context {
            run_as_user                = 1000
            run_as_non_root            = true
            read_only_root_filesystem  = true
            allow_privilege_escalation = false
          }

          env {
            name  = "CONFIG_MAP_NAME"
            value = kubernetes_config_map.postgres_operator.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_config_map.postgres_operator,
    kubernetes_cluster_role_binding.postgres_operator
  ]
}

resource "kubernetes_service" "postgres_operator" {
  metadata {
    name      = "postgres-operator"
    namespace = var.namespace
  }

  spec {
    selector = {
      name = "postgres-operator"
    }

    port {
      port        = 8080
      protocol    = "TCP"
      target_port = 8080
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment.postgres_operator]
}
