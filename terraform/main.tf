module "kubernetes_cluster" {
  source = "./modules/kubernetes"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace_v1" "rag" {
  depends_on = [module.kubernetes_cluster]
  metadata {
    name = "rag"
  }
}
