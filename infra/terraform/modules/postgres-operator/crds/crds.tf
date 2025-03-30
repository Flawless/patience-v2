# PostgreSQL CRD
resource "kubernetes_manifest" "postgresql_crd" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind       = "CustomResourceDefinition"
    metadata = {
      name = "postgresqls.acid.zalan.do"
    }
    spec = {
      group = "acid.zalan.do"
      names = {
        kind       = "postgresql"
        listKind   = "postgresqlList"
        plural     = "postgresqls"
        singular   = "postgresql"
        shortNames = ["pg"]
        categories = ["all"]
      }
      scope = "Namespaced"
      versions = [
        {
          name    = "v1"
          served  = true
          storage = true
          subresources = {
            status = {}
          }
          additionalPrinterColumns = [
            {
              name        = "Team"
              type        = "string"
              description = "Team responsible for Postgres cluster"
              jsonPath    = ".spec.teamId"
            },
            {
              name        = "Version"
              type        = "string"
              description = "PostgreSQL version"
              jsonPath    = ".spec.postgresql.version"
            },
            {
              name        = "Pods"
              type        = "integer"
              description = "Number of Pods per Postgres cluster"
              jsonPath    = ".spec.numberOfInstances"
            },
            {
              name        = "Volume"
              type        = "string"
              description = "Size of the bound volume"
              jsonPath    = ".spec.volume.size"
            },
            {
              name        = "CPU-Request"
              type        = "string"
              description = "Requested CPU for Postgres containers"
              jsonPath    = ".spec.resources.requests.cpu"
            },
            {
              name        = "Memory-Request"
              type        = "string"
              description = "Requested memory for Postgres containers"
              jsonPath    = ".spec.resources.requests.memory"
            },
            {
              name        = "Age"
              type        = "date"
              jsonPath    = ".metadata.creationTimestamp"
            },
            {
              name        = "Status"
              type        = "string"
              description = "Current sync status of postgresql resource"
              jsonPath    = ".status.PostgresClusterStatus"
            }
          ]
          schema = {
            openAPIV3Schema = {
              type = "object"
              required = [
                "kind",
                "apiVersion",
                "spec"
              ]
              properties = {
                kind = {
                  type = "string"
                  enum = [
                    "postgresql"
                  ]
                }
                apiVersion = {
                  type = "string"
                  enum = [
                    "acid.zalan.do/v1"
                  ]
                }
                spec = {
                  type = "object"
                  required = [
                    "numberOfInstances",
                    "teamId",
                    "postgresql",
                    "volume"
                  ]
                  properties = {
                    additionalVolumes = {
                      type = "array"
                      items = {
                        type = "object"
                        required = [
                          "name",
                          "mountPath",
                          "volumeSource"
                        ]
                        properties = {
                          isSubPathExpr = {
                            type = "boolean"
                          }
                          name = {
                            type = "string"
                          }
                          mountPath = {
                            type = "string"
                          }
                          subPath = {
                            type = "string"
                          }
                          targetContainers = {
                            type = "array"
                            nullable = true
                            items = {
                              type = "string"
                            }
                          }
                          volumeSource = {
                            type = "object"
                            "x-kubernetes-preserve-unknown-fields" = true
                          }
                        }
                      }
                    }
                    allowedSourceRanges = {
                      type = "array"
                      nullable = true
                      items = {
                        type = "string"
                        pattern = "^(\\d|[1-9]\\d|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d|[1-9]\\d|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d|[1-9]\\d|1\\d\\d|2[0-4]\\d|25[0-5])\\.(\\d|[1-9]\\d|1\\d\\d|2[0-4]\\d|25[0-5])\\/(\\d|[1-2]\\d|3[0-2])$"
                      }
                    }
                    clone = {
                      type = "object"
                      required = [
                        "cluster"
                      ]
                      properties = {
                        cluster = {
                          type = "string"
                        }
                        s3_endpoint = {
                          type = "string"
                        }
                        s3_access_key_id = {
                          type = "string"
                        }
                        s3_secret_access_key = {
                          type = "string"
                        }
                        s3_force_path_style = {
                          type = "boolean"
                        }
                        s3_wal_path = {
                          type = "string"
                        }
                        timestamp = {
                          type = "string"
                          pattern = "^([0-9]+)-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])[Tt]([01][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9]|60)(\\.[0-9]+)?(([+-]([01][0-9]|2[0-3]):[0-5][0-9]))$"
                        }
                        uid = {
                          format = "uuid"
                          type = "string"
                        }
                      }
                    }
                    connectionPooler = {
                      type = "object"
                      properties = {
                        dockerImage = {
                          type = "string"
                        }
                        maxDBConnections = {
                          type = "integer"
                        }
                        mode = {
                          type = "string"
                          enum = [
                            "session",
                            "transaction"
                          ]
                        }
                        numberOfInstances = {
                          type = "integer"
                          minimum = 1
                        }
                        resources = {
                          type = "object"
                          properties = {
                            limits = {
                              type = "object"
                              properties = {
                                cpu = {
                                  type = "string"
                                  pattern = "^(\\d+m|\\d+(\\.\\d{1,3})?)$"
                                }
                                memory = {
                                  type = "string"
                                  pattern = "^(\\d+(e\\d+)?|\\d+(\\.\\d+)?(e\\d+)?[EPTGMK]i?)$"
                                }
                              }
                            }
                            requests = {
                              type = "object"
                              properties = {
                                cpu = {
                                  type = "string"
                                  pattern = "^(\\d+m|\\d+(\\.\\d{1,3})?)$"
                                }
                                memory = {
                                  type = "string"
                                  pattern = "^(\\d+(e\\d+)?|\\d+(\\.\\d+)?(e\\d+)?[EPTGMK]i?)$"
                                }
                              }
                            }
                          }
                        }
                        schema = {
                          type = "string"
                        }
                        user = {
                          type = "string"
                        }
                      }
                    }
                    databases = {
                      type = "object"
                      additionalProperties = {
                        type = "string"
                      }
                    }
                    dockerImage = {
                      type = "string"
                    }
                    enableConnectionPooler = {
                      type = "boolean"
                    }
                    enableReplicaConnectionPooler = {
                      type = "boolean"
                    }
                    enableLogicalBackup = {
                      type = "boolean"
                    }
                    enableMasterLoadBalancer = {
                      type = "boolean"
                    }
                    enableMasterPoolerLoadBalancer = {
                      type = "boolean"
                    }
                    enableReplicaLoadBalancer = {
                      type = "boolean"
                    }
                    enableReplicaPoolerLoadBalancer = {
                      type = "boolean"
                    }
                    enableShmVolume = {
                      type = "boolean"
                    }
                    env = {
                      type = "array"
                      nullable = true
                      items = {
                        type = "object"
                        "x-kubernetes-preserve-unknown-fields" = true
                      }
                    }
                    init_containers = {
                      type = "array"
                      description = "deprecated"
                      nullable = true
                      items = {
                        type = "object"
                        "x-kubernetes-preserve-unknown-fields" = true
                      }
                    }
                    initContainers = {
                      type = "array"
                      nullable = true
                      items = {
                        type = "object"
                        "x-kubernetes-preserve-unknown-fields" = true
                      }
                    }
                    logicalBackupSchedule = {
                      type = "string"
                      pattern = "^(\\d+|\\*)(/\\d+)?(\\s+(\\d+|\\*)(/\\d+)?){4}$"
                    }
                    maintenanceWindows = {
                      type = "array"
                      items = {
                        type = "string"
                        pattern = "^\\ *((Mon|Tue|Wed|Thu|Fri|Sat|Sun):(2[0-3]|[01]?\\d):([0-5]?\\d)|(2[0-3]|[01]?\\d):([0-5]?\\d))-((2[0-3]|[01]?\\d):([0-5]?\\d)|(2[0-3]|[01]?\\d):([0-5]?\\d))\\ *$"
                      }
                    }
                    masterServiceAnnotations = {
                      type = "object"
                      additionalProperties = {
                        type = "string"
                      }
                    }
                    nodeAffinity = {
                      type = "object"
                      properties = {
                        preferredDuringSchedulingIgnoredDuringExecution = {
                          type = "array"
                          items = {
                            type = "object"
                            required = ["preference", "weight"]
                            properties = {
                              preference = {
                                type = "object"
                                properties = {
                                  matchExpressions = {
                                    type = "array"
                                    items = {
                                      type = "object"
                                      required = ["key", "operator"]
                                      properties = {
                                        key = {
                                          type = "string"
                                        }
                                        operator = {
                                          type = "string"
                                        }
                                        values = {
                                          type = "array"
                                          items = {
                                            type = "string"
                                          }
                                        }
                                      }
                                    }
                                  }
                                  matchFields = {
                                    type = "array"
                                    items = {
                                      type = "object"
                                      required = ["key", "operator"]
                                      properties = {
                                        key = {
                                          type = "string"
                                        }
                                        operator = {
                                          type = "string"
                                        }
                                        values = {
                                          type = "array"
                                          items = {
                                            type = "string"
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                              weight = {
                                format = "int32"
                                type = "integer"
                              }
                            }
                          }
                        }
                        requiredDuringSchedulingIgnoredDuringExecution = {
                          type = "object"
                          required = ["nodeSelectorTerms"]
                          properties = {
                            nodeSelectorTerms = {
                              type = "array"
                              items = {
                                type = "object"
                                properties = {
                                  matchExpressions = {
                                    type = "array"
                                    items = {
                                      type = "object"
                                      required = ["key", "operator"]
                                      properties = {
                                        key = {
                                          type = "string"
                                        }
                                        operator = {
                                          type = "string"
                                        }
                                        values = {
                                          type = "array"
                                          items = {
                                            type = "string"
                                          }
                                        }
                                      }
                                    }
                                  }
                                  matchFields = {
                                    type = "array"
                                    items = {
                                      type = "object"
                                      required = ["key", "operator"]
                                      properties = {
                                        key = {
                                          type = "string"
                                        }
                                        operator = {
                                          type = "string"
                                        }
                                        values = {
                                          type = "array"
                                          items = {
                                            type = "string"
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                    numberOfInstances = {
                      type = "integer"
                      minimum = 0
                    }
                    patroni = {
                      type = "object"
                      properties = {
                        failsafe_mode = {
                          type = "boolean"
                        }
                        initdb = {
                          type = "object"
                          additionalProperties = {
                            type = "string"
                          }
                        }
                        loop_wait = {
                          type = "integer"
                        }
                        maximum_lag_on_failover = {
                          type = "integer"
                        }
                        pg_hba = {
                          type = "array"
                          items = {
                            type = "string"
                          }
                        }
                        retry_timeout = {
                          type = "integer"
                        }
                        slots = {
                          type = "object"
                          additionalProperties = {
                            type = "object"
                            additionalProperties = {
                              type = "string"
                            }
                          }
                        }
                        synchronous_mode = {
                          type = "boolean"
                        }
                        synchronous_mode_strict = {
                          type = "boolean"
                        }
                        synchronous_node_count = {
                          type = "integer"
                        }
                        ttl = {
                          type = "integer"
                        }
                      }
                    }
                    podAnnotations = {
                      type = "object"
                      additionalProperties = {
                        type = "string"
                      }
                    }
                    pod_priority_class_name = {
                      type = "string"
                      description = "deprecated"
                    }
                    podPriorityClassName = {
                      type = "string"
                    }
                    postgresql = {
                      type = "object"
                      required = [
                        "version"
                      ]
                      properties = {
                        version = {
                          type = "string"
                          enum = [
                            "13",
                            "14",
                            "15",
                            "16",
                            "17"
                          ]
                        }
                        parameters = {
                          type = "object"
                          additionalProperties = {
                            type = "string"
                          }
                        }
                      }
                    }
                    preparedDatabases = {
                      type = "object"
                      additionalProperties = {
                        type = "object"
                        properties = {
                          defaultUsers = {
                            type = "boolean"
                          }
                          extensions = {
                            type = "object"
                            additionalProperties = {
                              type = "string"
                            }
                          }
                          schemas = {
                            type = "object"
                            additionalProperties = {
                              type = "object"
                              properties = {
                                defaultUsers = {
                                  type = "boolean"
                                }
                                defaultRoles = {
                                  type = "boolean"
                                }
                              }
                            }
                          }
                          secretNamespace = {
                            type = "string"
                          }
                        }
                      }
                    }
                    replicaLoadBalancer = {
                      type = "boolean"
                      description = "deprecated"
                    }
                    replicaServiceAnnotations = {
                      type = "object"
                      additionalProperties = {
                        type = "string"
                      }
                    }
                    resources = {
                      type = "object"
                      properties = {
                        limits = {
                          type = "object"
                          properties = {
                            cpu = {
                              type = "string"
                              pattern = "^(\\d+m|\\d+(\\.\\d{1,3})?)$"
                            }
                            memory = {
                              type = "string"
                              pattern = "^(\\d+(e\\d+)?|\\d+(\\.\\d+)?(e\\d+)?[EPTGMK]i?)$"
                            }
                            hugepages-2Mi = {
                              type = "string"
                              pattern = "^(\\d+(e\\d+)?|\\d+(\\.\\d+)?(e\\d+)?[EPTGMK]i?)$"
                            }
                            hugepages-1Gi = {
                              type = "string"
                              pattern = "^(\\d+(e\\d+)?|\\d+(\\.\\d+)?(e\\d+)?[EPTGMK]i?)$"
                            }
                          }
                        }
                        requests = {
                          type = "object"
                          properties = {
                            cpu = {
                              type = "string"
                              pattern = "^(\\d+m|\\d+(\\.\\d{1,3})?)$"
                            }
                            memory = {
                              type = "string"
                              pattern = "^(\\d+(e\\d+)?|\\d+(\\.\\d+)?(e\\d+)?[EPTGMK]i?)$"
                            }
                            hugepages-2Mi = {
                              type = "string"
                              pattern = "^(\\d+(e\\d+)?|\\d+(\\.\\d+)?(e\\d+)?[EPTGMK]i?)$"
                            }
                            hugepages-1Gi = {
                              type = "string"
                              pattern = "^(\\d+(e\\d+)?|\\d+(\\.\\d+)?(e\\d+)?[EPTGMK]i?)$"
                            }
                          }
                        }
                      }
                    }
                    schedulerName = {
                      type = "string"
                    }
                    serviceAnnotations = {
                      type = "object"
                      additionalProperties = {
                        type = "string"
                      }
                    }
                    sidecars = {
                      type = "array"
                      nullable = true
                      items = {
                        type = "object"
                        "x-kubernetes-preserve-unknown-fields" = true
                      }
                    }
                    spiloRunAsUser = {
                      type = "integer"
                    }
                    spiloRunAsGroup = {
                      type = "integer"
                    }
                    spiloFSGroup = {
                      type = "integer"
                    }
                    standby = {
                      type = "object"
                      properties = {
                        s3_wal_path = {
                          type = "string"
                        }
                        gs_wal_path = {
                          type = "string"
                        }
                        standby_host = {
                          type = "string"
                        }
                        standby_port = {
                          type = "string"
                        }
                      }
                      oneOf = [
                        {
                          required = [
                            "s3_wal_path"
                          ]
                        },
                        {
                          required = [
                            "gs_wal_path"
                          ]
                        },
                        {
                          required = [
                            "standby_host"
                          ]
                        }
                      ]
                    }
                    teamId = {
                      type = "string"
                    }
                    tls = {
                      type = "object"
                      required = [
                        "secretName"
                      ]
                      properties = {
                        secretName = {
                          type = "string"
                        }
                        certificateFile = {
                          type = "string"
                        }
                        privateKeyFile = {
                          type = "string"
                        }
                        caFile = {
                          type = "string"
                        }
                        caSecretName = {
                          type = "string"
                        }
                      }
                    }
                    tolerations = {
                      type = "array"
                      items = {
                        type = "object"
                        properties = {
                          key = {
                            type = "string"
                          }
                          operator = {
                            type = "string"
                            enum = [
                              "Equal",
                              "Exists"
                            ]
                          }
                          value = {
                            type = "string"
                          }
                          effect = {
                            type = "string"
                            enum = [
                              "NoExecute",
                              "NoSchedule",
                              "PreferNoSchedule"
                            ]
                          }
                          tolerationSeconds = {
                            type = "integer"
                          }
                        }
                      }
                    }
                    useLoadBalancer = {
                      type = "boolean"
                      description = "deprecated"
                    }
                    users = {
                      type = "object"
                      additionalProperties = {
                        type = "array"
                        nullable = true
                        items = {
                          type = "string"
                          enum = [
                            "bypassrls",
                            "BYPASSRLS",
                            "nobypassrls",
                            "NOBYPASSRLS",
                            "createdb",
                            "CREATEDB",
                            "nocreatedb",
                            "NOCREATEDB",
                            "createrole",
                            "CREATEROLE",
                            "nocreaterole",
                            "NOCREATEROLE",
                            "inherit",
                            "INHERIT",
                            "noinherit",
                            "NOINHERIT",
                            "login",
                            "LOGIN",
                            "nologin",
                            "NOLOGIN",
                            "replication",
                            "REPLICATION",
                            "noreplication",
                            "NOREPLICATION",
                            "superuser",
                            "SUPERUSER",
                            "nosuperuser",
                            "NOSUPERUSER"
                          ]
                        }
                      }
                    }
                    usersIgnoringSecretRotation = {
                      type = "array"
                      nullable = true
                      items = {
                        type = "string"
                      }
                    }
                    usersWithInPlaceSecretRotation = {
                      type = "array"
                      nullable = true
                      items = {
                        type = "string"
                      }
                    }
                    usersWithSecretRotation = {
                      type = "array"
                      nullable = true
                      items = {
                        type = "string"
                      }
                    }
                    volume = {
                      type = "object"
                      required = [
                        "size"
                      ]
                      properties = {
                        isSubPathExpr = {
                          type = "boolean"
                        }
                        iops = {
                          type = "integer"
                        }
                        selector = {
                          type = "object"
                          properties = {
                            matchExpressions = {
                              type = "array"
                              items = {
                                type = "object"
                                required = [
                                  "key",
                                  "operator"
                                ]
                                properties = {
                                  key = {
                                    type = "string"
                                  }
                                  operator = {
                                    type = "string"
                                    enum = [
                                      "DoesNotExist",
                                      "Exists",
                                      "In",
                                      "NotIn"
                                    ]
                                  }
                                  values = {
                                    type = "array"
                                    items = {
                                      type = "string"
                                    }
                                  }
                                }
                              }
                            }
                            matchLabels = {
                              type = "object"
                              "x-kubernetes-preserve-unknown-fields" = true
                            }
                          }
                        }
                        size = {
                          type = "string"
                          pattern = "^(\\d+(e\\d+)?|\\d+(\\.\\d+)?(e\\d+)?[EPTGMK]i?)$"
                        }
                        storageClass = {
                          type = "string"
                        }
                        subPath = {
                          type = "string"
                        }
                        throughput = {
                          type = "integer"
                        }
                      }
                    }
                  }
                }
                status = {
                  type = "object"
                  additionalProperties = {
                    type = "string"
                  }
                }
              }
            }
          }
        }
      ]
    }
  }
}

# OperatorConfiguration CRD
resource "kubernetes_manifest" "operatorconfiguration_crd" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind       = "CustomResourceDefinition"
    metadata = {
      name = "operatorconfigurations.acid.zalan.do"
    }
    spec = {
      group = "acid.zalan.do"
      names = {
        kind       = "OperatorConfiguration"
        listKind   = "OperatorConfigurationList"
        plural     = "operatorconfigurations"
        singular   = "operatorconfiguration"
        shortNames = ["opconfig"]
        categories = ["all"]
      }
      scope = "Namespaced"
      versions = [
        {
          name    = "v1"
          served  = true
          storage = true
          subresources = {
            status = {}
          }
          additionalPrinterColumns = [
            {
              name        = "Image"
              type        = "string"
              description = "Spilo image to be used for Pods"
              jsonPath    = ".configuration.docker_image"
            },
            {
              name        = "Cluster-Label"
              type        = "string"
              description = "Label for K8s resources created by operator"
              jsonPath    = ".configuration.kubernetes.cluster_name_label"
            },
            {
              name        = "Service-Account"
              type        = "string"
              description = "Name of service account to be used"
              jsonPath    = ".configuration.kubernetes.pod_service_account_name"
            },
            {
              name        = "Min-Instances"
              type        = "integer"
              description = "Minimum number of instances per Postgres cluster"
              jsonPath    = ".configuration.min_instances"
            },
            {
              name        = "Age"
              type        = "date"
              jsonPath    = ".metadata.creationTimestamp"
            }
          ]
          schema = {
            openAPIV3Schema = {
              type = "object"
              required = [
                "kind",
                "apiVersion",
                "configuration"
              ]
              properties = {
                kind = {
                  type = "string"
                  enum = [
                    "OperatorConfiguration"
                  ]
                }
                apiVersion = {
                  type = "string"
                  enum = [
                    "acid.zalan.do/v1"
                  ]
                }
                configuration = {
                  type = "object"
                  properties = {
                    crd_categories = {
                      type = "array"
                      nullable = true
                      items = {
                        type = "string"
                      }
                    }
                    docker_image = {
                      type    = "string"
                      default = "ghcr.io/zalando/spilo-17:4.0-p2"
                    }
                    enable_crd_registration = {
                      type    = "boolean"
                      default = true
                    }
                    enable_crd_validation = {
                      type        = "boolean"
                      description = "deprecated"
                      default     = true
                    }
                    enable_lazy_spilo_upgrade = {
                      type    = "boolean"
                      default = false
                    }
                    enable_pgversion_env_var = {
                      type    = "boolean"
                      default = true
                    }
                    enable_shm_volume = {
                      type    = "boolean"
                      default = true
                    }
                    enable_spilo_wal_path_compat = {
                      type    = "boolean"
                      default = false
                    }
                    enable_team_id_clustername_prefix = {
                      type    = "boolean"
                      default = false
                    }
                    etcd_host = {
                      type    = "string"
                      default = ""
                    }
                    ignore_instance_limits_annotation_key = {
                      type = "string"
                    }
                    kubernetes_use_configmaps = {
                      type    = "boolean"
                      default = false
                    }
                    max_instances = {
                      type        = "integer"
                      description = "-1 = disabled"
                      minimum     = -1
                      default     = -1
                    }
                    min_instances = {
                      type        = "integer"
                      description = "-1 = disabled"
                      minimum     = -1
                      default     = -1
                    }
                    resync_period = {
                      type    = "string"
                      default = "30m"
                    }
                    repair_period = {
                      type    = "string"
                      default = "5m"
                    }
                    set_memory_request_to_limit = {
                      type    = "boolean"
                      default = false
                    }
                    sidecar_docker_images = {
                      type = "object"
                      additionalProperties = {
                        type = "string"
                      }
                    }
                    sidecars = {
                      type     = "array"
                      nullable = true
                      items = {
                        type                                 = "object"
                        "x-kubernetes-preserve-unknown-fields" = true
                      }
                    }
                    workers = {
                      type    = "integer"
                      minimum = 1
                      default = 8
                    }
                    # Additional configuration sections like users, major_version_upgrade, kubernetes, etc.
                    # For brevity, I've focused on the core configuration properties
                  }
                }
                status = {
                  type = "object"
                  additionalProperties = {
                    type = "string"
                  }
                }
              }
            }
          }
        }
      ]
    }
  }
}

# PostgresTeam CRD
resource "kubernetes_manifest" "postgresteam_crd" {
  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind       = "CustomResourceDefinition"
    metadata = {
      name = "postgresteams.acid.zalan.do"
    }
    spec = {
      group = "acid.zalan.do"
      names = {
        kind       = "PostgresTeam"
        listKind   = "PostgresTeamList"
        plural     = "postgresteams"
        singular   = "postgresteam"
        shortNames = ["pgteam"]
        categories = ["all"]
      }
      scope = "Namespaced"
      versions = [
        {
          name    = "v1"
          served  = true
          storage = true
          subresources = {
            status = {}
          }
          schema = {
            openAPIV3Schema = {
              type = "object"
              required = [
                "kind",
                "apiVersion",
                "spec"
              ]
              properties = {
                kind = {
                  type = "string"
                  enum = [
                    "PostgresTeam"
                  ]
                }
                apiVersion = {
                  type = "string"
                  enum = [
                    "acid.zalan.do/v1"
                  ]
                }
                spec = {
                  type = "object"
                  properties = {
                    additionalSuperuserTeams = {
                      type        = "object"
                      description = "Map for teamId and associated additional superuser teams"
                      additionalProperties = {
                        type        = "array"
                        nullable    = true
                        description = "List of teams to become Postgres superusers"
                        items = {
                          type = "string"
                        }
                      }
                    }
                    additionalTeams = {
                      type        = "object"
                      description = "Map for teamId and associated additional teams"
                      additionalProperties = {
                        type        = "array"
                        nullable    = true
                        description = "List of teams whose members will also be added to the Postgres cluster"
                        items = {
                          type = "string"
                        }
                      }
                    }
                    additionalMembers = {
                      type        = "object"
                      description = "Map for teamId and associated additional users"
                      additionalProperties = {
                        type        = "array"
                        nullable    = true
                        description = "List of users who will also be added to the Postgres cluster"
                        items = {
                          type = "string"
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      ]
    }
  }
}
