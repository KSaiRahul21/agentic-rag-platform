module "kubernetes_cluster" {
  source = "./modules/kubernetes"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace_v1" "rag" {
  metadata {
    name = "rag"
  }
}

module "qdrant" {
  source = "./modules/qdrant"
}