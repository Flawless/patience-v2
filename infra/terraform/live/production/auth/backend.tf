terraform {
  backend "kubernetes" {
    config_path   = "../../../kubeconfig.yaml"
    namespace     = "terraform"
    secret_suffix = "auth"
  }
}
