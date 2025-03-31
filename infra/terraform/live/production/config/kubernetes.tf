locals {
  k8s_config = {
    host     = "https://kube.aidbox.dev.last-try.org:6443"
  }
}

output "k8s_config" {
  value = local.k8s_config
}
