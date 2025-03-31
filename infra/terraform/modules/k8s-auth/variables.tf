variable "service_accounts" {
  description = "Map of service accounts with their assigned roles"
  type = map(object({
    namespace = string
    cluster_roles = list(string)
    namespace_roles = map(list(string))
  }))
}

variable "cluster_roles" {
  description = "Map of cluster roles and their rules"
  type = map(object({
    rules = list(object({
      api_groups = list(string)
      resources = list(string)
      resource_names = optional(list(string))
      verbs = list(string)
    }))
  }))
}

variable "namespace_roles" {
  description = "Map of namespace roles and their rules"
  type = map(object({
    namespace = string
    rules = list(object({
      api_groups = list(string)
      resources = list(string)
      resource_names = optional(list(string))
      verbs = list(string)
    }))
  }))
}

variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
}

