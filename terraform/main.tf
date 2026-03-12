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

module "qdrant" {
  source = "./modules/qdrant"
  depends_on = [kubernetes_namespace_v1.rag]

}

module "ollama" {
  source = "./modules/ollama"
  depends_on = [kubernetes_namespace_v1.rag]

}